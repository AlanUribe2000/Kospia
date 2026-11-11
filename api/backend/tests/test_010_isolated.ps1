param(
    [string]$Docker = 'C:\Program Files\Docker\Docker\resources\bin\docker.exe',
    [string]$CompanionMigration = 'C:\Users\Nico\Desktop\Kospia-4B1-remote\api\backend\migrations\008_add_help_cards.sql'
)

$ErrorActionPreference = 'Stop'
$container = 'kospia-010-test-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
$migrationDirectory = Join-Path (Split-Path $PSScriptRoot) 'migrations'
$started = $false

function Invoke-Sql([string]$Database, [string]$Sql, [bool]$ExpectFailure = $false) {
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $Sql | & $Docker exec -i $container psql -X -U postgres -d $Database -v ON_ERROR_STOP=1
        $status = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if (($status -eq 0) -eq $ExpectFailure) {
        throw "Unexpected psql exit code $status in $Database"
    }
}

function Invoke-Migration([string]$Database, [string]$Path, [bool]$ExpectFailure = $false) {
    Invoke-Sql $Database (Get-Content -Raw -LiteralPath $Path) $ExpectFailure
}

function New-Fixture([string]$Database) {
    & $Docker exec $container createdb -U postgres $Database
    if ($LASTEXITCODE -ne 0) { throw "Cannot create fixture database $Database" }
    Invoke-Sql $Database @'
CREATE TABLE public.species (id text PRIMARY KEY);
CREATE TABLE public.questions (id text PRIMARY KEY, question_text text, field_name text, required_part text, order_index integer, is_active boolean);
CREATE TABLE public.question_options (id text PRIMARY KEY, question_id text, option_text text, value_key text, order_index integer);
CREATE TABLE public.species_traits (id text PRIMARY KEY, species_id text, question_id text, option_id text);
INSERT INTO public.species VALUES ('sp-1');
INSERT INTO public.questions (id, is_active) VALUES ('q-1', true), ('q-2', true), ('q-forma-hoja', true);
INSERT INTO public.question_options (id, question_id) VALUES ('o-1', 'q-1'), ('o-2', 'q-2'), ('legacy-unused', 'q-forma-hoja');
INSERT INTO public.species_traits VALUES ('t-1', 'sp-1', 'q-1', 'o-1');
'@
}

function Test-OptionLock {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Docker
    $startInfo.Arguments = "exec -i $container psql -X -qAt -U postgres -d scenario_a -v ON_ERROR_STOP=1"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($startInfo)
    try {
        $process.StandardInput.WriteLine("BEGIN; SELECT id FROM public.question_options WHERE id = 'o-1' FOR KEY SHARE; SELECT 'LOCK_HELD';")
        $process.StandardInput.Flush()
        do {
            $line = $process.StandardOutput.ReadLine()
            if ($null -eq $line) { throw 'Locking session ended before acquiring the lock' }
        } while ($line -ne 'LOCK_HELD')
        Invoke-Sql 'scenario_a' @'
SET lock_timeout = '200ms';
DO $$ BEGIN
    BEGIN
        DELETE FROM public.question_options WHERE id = 'o-1';
        RAISE EXCEPTION 'delete did not wait for KEY SHARE';
    EXCEPTION WHEN lock_not_available THEN NULL; END;
    BEGIN
        UPDATE public.question_options SET question_id = 'q-2' WHERE id = 'o-1';
        RAISE EXCEPTION 'question change did not wait for KEY SHARE';
    EXCEPTION WHEN lock_not_available THEN NULL; END;
END $$;
'@
        Write-Output 'PASS concurrent option delete and move wait for KEY SHARE'
    } finally {
        $process.StandardInput.WriteLine('ROLLBACK;')
        $process.StandardInput.Close()
        $process.WaitForExit()
        $process.Dispose()
    }
}

$assertIntegrity = @'
DO $$
BEGIN
    IF (SELECT count(*) FROM public.species_traits) <> 1 THEN RAISE EXCEPTION 'trait row changed'; END IF;
    IF (SELECT count(*) FROM pg_constraint WHERE conrelid = 'public.species_traits'::regclass AND contype = 'f' AND convalidated) <> 3 THEN RAISE EXCEPTION 'missing validated foreign keys'; END IF;
    BEGIN
        INSERT INTO public.species_traits VALUES ('dup', 'sp-1', 'q-1', 'o-1');
        RAISE EXCEPTION 'duplicate accepted';
    EXCEPTION WHEN unique_violation THEN NULL; END;
    BEGIN
        INSERT INTO public.species_traits VALUES ('null', 'sp-1', NULL, 'o-1');
        RAISE EXCEPTION 'null accepted';
    EXCEPTION WHEN not_null_violation THEN NULL; END;
    BEGIN
        INSERT INTO public.species_traits VALUES ('wrong', 'sp-1', 'q-2', 'o-1');
        RAISE EXCEPTION 'wrong question accepted';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
    BEGIN
        INSERT INTO public.species_traits VALUES ('missing', 'missing', 'q-1', 'o-1');
        RAISE EXCEPTION 'missing species accepted';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
    BEGIN
        DELETE FROM public.question_options WHERE id = 'o-1';
        RAISE EXCEPTION 'referenced option deleted';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
    BEGIN
        UPDATE public.question_options SET question_id = 'q-2' WHERE id = 'o-1';
        RAISE EXCEPTION 'referenced option moved';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
    BEGIN
        DELETE FROM public.species WHERE id = 'sp-1';
        RAISE EXCEPTION 'referenced species deleted';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
    BEGIN
        DELETE FROM public.questions WHERE id = 'q-1';
        RAISE EXCEPTION 'referenced question deleted';
    EXCEPTION WHEN foreign_key_violation THEN NULL; END;
END
$$;
'@

try {
    & $Docker run --pull=never --name $container --network none --tmpfs /var/lib/postgresql/data --rm -d -e POSTGRES_HOST_AUTH_METHOD=trust postgres:16
    if ($LASTEXITCODE -ne 0) { throw 'Cannot start isolated PostgreSQL' }
    $started = $true
    $inspection = & $Docker inspect $container | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or $inspection[0].HostConfig.NetworkMode -ne 'none' -or
        -not $inspection[0].HostConfig.AutoRemove -or
        $null -eq $inspection[0].HostConfig.Tmpfs.PSObject.Properties['/var/lib/postgresql/data'] -or
        $inspection[0].Mounts.Count -ne 0 -or
        $inspection[0].HostConfig.PortBindings.PSObject.Properties.Count -gt 0) {
        throw 'Container isolation configuration is unexpected'
    }
    Write-Output 'PASS container isolation'
    & $Docker exec $container sh -c 'n=0; until pg_isready -U postgres >/dev/null 2>&1; do n=$((n+1)); [ "$n" -lt 10000 ] || exit 1; done'
    if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL did not become ready' }

    foreach ($scenario in @('scenario_a', 'scenario_b')) {
        if ($scenario -eq 'scenario_b' -and -not (Test-Path -LiteralPath $CompanionMigration)) {
            Write-Output 'SKIP scenario B: companion migration not available'
            continue
        }
        New-Fixture $scenario
        if ($scenario -eq 'scenario_b') {
            Invoke-Sql $scenario "INSERT INTO public.question_options (id, question_id) VALUES ('legacy-used', 'q-forma-hoja'); INSERT INTO public.species_traits VALUES ('t-legacy', 'sp-1', 'q-forma-hoja', 'legacy-used');"
            Invoke-Migration $scenario $CompanionMigration
        }
        Invoke-Migration $scenario (Join-Path $migrationDirectory '009_add_help_cards.sql')
        Invoke-Migration $scenario (Join-Path $migrationDirectory '009_add_help_cards.sql')
        Invoke-Migration $scenario (Join-Path $migrationDirectory '010_species_traits_integrity.sql')
        Invoke-Migration $scenario (Join-Path $migrationDirectory '010_species_traits_integrity.sql')
        Invoke-Migration $scenario (Join-Path $migrationDirectory '009_add_help_cards.sql')
        $scenarioAssertions = if ($scenario -eq 'scenario_b') {
            $assertIntegrity.Replace('(SELECT count(*) FROM public.species_traits) <> 1', '(SELECT count(*) FROM public.species_traits) <> 2')
        } else { $assertIntegrity }
        Invoke-Sql $scenario $scenarioAssertions
        $expectedLegacy = if ($scenario -eq 'scenario_a') { 1 } else { 0 }
        Invoke-Sql $scenario "DO `$$ BEGIN IF (SELECT count(*) FROM public.question_options WHERE id = 'legacy-unused') <> $expectedLegacy THEN RAISE EXCEPTION 'unexpected companion cleanup'; END IF; END `$$;"
        if ($scenario -eq 'scenario_b') {
            Invoke-Sql $scenario "DO `$$ BEGIN IF NOT EXISTS (SELECT 1 FROM public.question_options WHERE id = 'legacy-used') OR NOT EXISTS (SELECT 1 FROM public.species_traits WHERE id = 't-legacy') THEN RAISE EXCEPTION 'referenced legacy data removed'; END IF; END `$$;"
        }
        Write-Output "PASS $scenario"
    }

    Test-OptionLock

    New-Fixture 'compatible_fk'
    Invoke-Sql 'compatible_fk' 'ALTER TABLE public.species_traits ADD CONSTRAINT existing_option_fk FOREIGN KEY (option_id) REFERENCES public.question_options(id);'
    Invoke-Migration 'compatible_fk' (Join-Path $migrationDirectory '010_species_traits_integrity.sql')
    Invoke-Migration 'compatible_fk' (Join-Path $migrationDirectory '010_species_traits_integrity.sql')
    Invoke-Sql 'compatible_fk' @'
DO $$ BEGIN
    IF (SELECT count(*) FROM pg_constraint WHERE conrelid = 'public.species_traits'::regclass AND contype = 'f' AND convalidated) <> 4
       OR NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'public.species_traits'::regclass AND conname = 'existing_option_fk')
       OR (SELECT count(*) FROM public.species_traits) <> 1 THEN
        RAISE EXCEPTION 'compatible existing foreign key was not preserved';
    END IF;
END $$;
'@
    Write-Output 'PASS compatible existing foreign key preserved'

    $invalidCases = @{
        invalid_null = "INSERT INTO public.species_traits VALUES ('bad', 'sp-1', NULL, 'o-1');"
        invalid_missing = "INSERT INTO public.species_traits VALUES ('bad', 'missing', 'q-1', 'o-1');"
        invalid_pair = "INSERT INTO public.species_traits VALUES ('bad', 'sp-1', 'q-2', 'o-1');"
        invalid_duplicate = "INSERT INTO public.species_traits VALUES ('bad', 'sp-1', 'q-1', 'o-1');"
        invalid_cascade = 'ALTER TABLE public.species_traits ADD CONSTRAINT existing_cascade FOREIGN KEY (option_id) REFERENCES public.question_options(id) ON DELETE CASCADE;'
        invalid_index = 'CREATE INDEX uq_010_question_options_id_question ON public.question_options (question_id);'
    }
    foreach ($case in $invalidCases.GetEnumerator()) {
        New-Fixture $case.Key
        Invoke-Sql $case.Key $case.Value
        Invoke-Migration $case.Key (Join-Path $migrationDirectory '010_species_traits_integrity.sql') $true
        $expectedCount = if ($case.Key -in @('invalid_cascade', 'invalid_index')) { 1 } else { 2 }
        Invoke-Sql $case.Key "DO `$$ BEGIN IF (SELECT count(*) FROM public.species_traits) <> $expectedCount OR EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid = 'public.species_traits'::regclass AND attname = 'species_id' AND attnotnull) OR to_regclass('public.uq_010_species_traits_species_question_option') IS NOT NULL THEN RAISE EXCEPTION 'migration was not rolled back'; END IF; END `$$;"
        Write-Output "PASS $($case.Key) rejected without changes"
    }
} finally {
    if ($started) {
        & $Docker stop $container
        if ($LASTEXITCODE -ne 0) { Write-Warning "Could not stop own container $container" }
    }
}