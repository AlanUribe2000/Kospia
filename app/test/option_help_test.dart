import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/data/repositories/species_repository.dart';

void main() {
  OptionHelp help({String? description, List<OptionPhoto> photos = const []}) =>
      OptionHelp(
        optionId: 'option',
        valueKey: 'value',
        optionText: 'Opcion',
        description: description,
        iconAttachmentId: null,
        photos: photos,
      );

  test('shows help for description or photos, but not empty content', () {
    expect(help().hasContent, isFalse);
    expect(help(description: '  ').hasContent, isFalse);
    expect(help(description: 'Descripcion').hasContent, isTrue);
    expect(
      help(
        photos: const [
          OptionPhoto(
            id: 'photo',
            optionId: 'option',
            orderIndex: 0,
            fileExtension: 'jpg',
          ),
        ],
      ).hasContent,
      isTrue,
    );
  });
}
