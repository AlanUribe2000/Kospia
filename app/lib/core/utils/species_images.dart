/// Utilidad que mapea nombres científicos a sus imágenes en assets/images/Catalogs.
/// Cada especie tiene una carpeta con su nombre científico que contiene las fotos.
class SpeciesImages {
  SpeciesImages._();

  /// Obtiene la lista de rutas de assets de imágenes para una especie.
  /// Retorna lista vacía si la especie no tiene imágenes registradas.
  static List<String> getImages(String scientificName) {
    return _imageMap[scientificName] ?? [];
  }

  /// Obtiene la primera imagen disponible para una especie, o null si no hay.
  static String? getFirstImage(String scientificName) {
    final images = _imageMap[scientificName];
    if (images == null || images.isEmpty) return null;
    return images.first;
  }

  /// Verifica si una especie tiene imágenes disponibles.
  static bool hasImages(String scientificName) {
    final images = _imageMap[scientificName];
    return images != null && images.isNotEmpty;
  }

  /// Mapa completo: nombre científico → lista de rutas de assets.
  static const Map<String, List<String>> _imageMap = {
    'Acaena pinnatifida': [
      'assets/images/Catalogs/Acaena pinnatifida/16.jpeg',
      'assets/images/Catalogs/Acaena pinnatifida/17.jpeg',
    ],
    'Adesmia candida': [
      'assets/images/Catalogs/Adesmia candida/44.jpeg',
      'assets/images/Catalogs/Adesmia candida/IMG_20221128_124824.jpg',
      'assets/images/Catalogs/Adesmia candida/IMG_20221128_124835.jpg',
    ],
    'Adesmia lotoides': [
      'assets/images/Catalogs/Adesmia lotoides/12.jpeg',
      'assets/images/Catalogs/Adesmia lotoides/8.jpeg',
    ],
    'Adesmia villosa': [
      'assets/images/Catalogs/Adesmia villosa/78.jpeg',
      'assets/images/Catalogs/Adesmia villosa/79.jpeg',
    ],
    'Adesmia volckmannii': [
      'assets/images/Catalogs/Adesmia volckmannii/85.jpeg',
      'assets/images/Catalogs/Adesmia volckmannii/DSC_0200.JPG',
      'assets/images/Catalogs/Adesmia volckmannii/IMG_20231209_134701.jpg',
      'assets/images/Catalogs/Adesmia volckmannii/IMG_20231210_162816.jpg',
      'assets/images/Catalogs/Adesmia volckmannii/IMG_20241119_143631.jpg',
    ],
    'Amsinckia calycina': [
      'assets/images/Catalogs/Amsinckia calycina/IMG_20180919_131900.jpg',
      'assets/images/Catalogs/Amsinckia calycina/IMG_20181021_151748.jpg',
      'assets/images/Catalogs/Amsinckia calycina/IMG_20220830_172000.jpg',
    ],
    'Anarthrophyllum desiderata': [
      'assets/images/Catalogs/Anarthrophyllum desidesatum/59.jpeg',
      'assets/images/Catalogs/Anarthrophyllum desidesatum/61.jpeg',
      'assets/images/Catalogs/Anarthrophyllum desidesatum/62.jpeg',
      'assets/images/Catalogs/Anarthrophyllum desidesatum/63.jpeg',
    ],
    'Arjona tuberosa': [
      'assets/images/Catalogs/Arjona tuberosa/11.jpeg',
      'assets/images/Catalogs/Arjona tuberosa/54.jpeg',
      'assets/images/Catalogs/Arjona tuberosa/IMG_20221116_105135.jpg',
      'assets/images/Catalogs/Arjona tuberosa/IMG_20221121_115110.jpg',
    ],
    'Astragalus cruckshanskii': [
      'assets/images/Catalogs/Astragalus cruckshanskii/37.jpeg',
      'assets/images/Catalogs/Astragalus cruckshanskii/IMG_20180919_131501.jpg',
      'assets/images/Catalogs/Astragalus cruckshanskii/IMG_20221128_124651.jpg',
    ],
    'Atriplex lampa': [
      'assets/images/Catalogs/Atriplex lampa/66.jpeg',
      'assets/images/Catalogs/Atriplex lampa/IMG_20220830_172429.jpg',
      'assets/images/Catalogs/Atriplex lampa/IMG_20221007_151031.jpg',
      'assets/images/Catalogs/Atriplex lampa/IMG_20221209_174714.jpg',
    ],
    'Austrocactus bertinii': [
      'assets/images/Catalogs/Austrocactus bertinii/45.jpeg',
      'assets/images/Catalogs/Austrocactus bertinii/IMG_20221007_105810.jpg',
    ],
    'Azorella prolifera': [
      'assets/images/Catalogs/Azorella prolifera/IMG_20181213_145552.jpg',
      'assets/images/Catalogs/Azorella prolifera/IMG_20231209_134135.jpg',
      'assets/images/Catalogs/Azorella prolifera/IMG_20231209_134315.jpg',
      'assets/images/Catalogs/Azorella prolifera/IMG_20250204_133457.jpg',
      'assets/images/Catalogs/Azorella prolifera/IMG_20250204_133805.jpg',
    ],
    'Baccharis darwinii': [
      'assets/images/Catalogs/Baccharis darwinii/IMG_20181021_163047.jpg',
      'assets/images/Catalogs/Baccharis darwinii/IMG_20221209_174745.jpg',
    ],
    'Berberis microphylla': [
      'assets/images/Catalogs/Berberis microphylla/5.jpeg',
      'assets/images/Catalogs/Berberis microphylla/55.jpeg',
      'assets/images/Catalogs/Berberis microphylla/6.jpeg',
      'assets/images/Catalogs/Berberis microphylla/7.jpeg',
      'assets/images/Catalogs/Berberis microphylla/IMG_20180824_131946.jpg',
      'assets/images/Catalogs/Berberis microphylla/IMG_20180919_142637.jpg',
      'assets/images/Catalogs/Berberis microphylla/IMG_20180919_142717.jpg',
      'assets/images/Catalogs/Berberis microphylla/IMG_20231210_162446.jpg',
      'assets/images/Catalogs/Berberis microphylla/IMG_20231210_162452.jpg',
      'assets/images/Catalogs/Berberis microphylla/WhatsApp Image 2025-11-19 at 10.14.43.jpeg',
    ],
    'Xiphodesma anthemoides': [
      'assets/images/Catalogs/Boopis anthemoides/IMG-20221007-WA0007.jpg',
    ],
    'Brachyclados caespitosus': [
      'assets/images/Catalogs/Brachyclados caespitosus/31.jpeg',
      'assets/images/Catalogs/Brachyclados caespitosus/33.jpeg',
      'assets/images/Catalogs/Brachyclados caespitosus/IMG_20221210_181126.jpg',
      'assets/images/Catalogs/Brachyclados caespitosus/IMG_20221210_181236.jpg',
    ],
    'Calceolaria polyrhiza': [
      'assets/images/Catalogs/Calceolaria polyrhiza/68.jpeg',
      'assets/images/Catalogs/Calceolaria polyrhiza/DSCN1409.JPG',
      'assets/images/Catalogs/Calceolaria polyrhiza/IMG_20221007_115346.jpg',
      'assets/images/Catalogs/Calceolaria polyrhiza/IMG_20241119_153519.jpg',
    ],
    'Camissonia dentata': [
      'assets/images/Catalogs/Camissonia dentata/WhatsApp Image 2025-11-19 at 10.07.39 (2).jpeg',
    ],
    'Cerastium arvense': [
      'assets/images/Catalogs/Cerastium arvense/IMG_20181004_102049.jpg',
      'assets/images/Catalogs/Cerastium arvense/WhatsApp Image 2023-10-10 at 18.58.59.jpeg',
    ],
    'Chuquiraga aurea': [
      'assets/images/Catalogs/Chuquiraga aurea/82.jpeg',
      'assets/images/Catalogs/Chuquiraga aurea/IMG_20221121_114940.jpg',
      'assets/images/Catalogs/Chuquiraga aurea/IMG_20221128_124441.jpg',
      'assets/images/Catalogs/Chuquiraga aurea/IMG_20221128_124450.jpg',
      'assets/images/Catalogs/Chuquiraga aurea/IMG_20230114_173420.jpg',
    ],
    'Chiquiraga avellanedae': [
      'assets/images/Catalogs/Chuquiraga avellanedae/75.jpeg',
    ],
    'Colliguaja integerrima': [
      'assets/images/Catalogs/Colliguaja integerrima/21.jpeg',
      'assets/images/Catalogs/Colliguaja integerrima/4.jpeg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20180824_121807.jpg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20180824_122400.jpg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20220518_151827.jpg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20220912_122707 - copia.jpg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20221007_110252.jpg',
      'assets/images/Catalogs/Colliguaja integerrima/IMG_20221116_114807.jpg',
    ],
    'Duseniella patagonica': [
      'assets/images/Catalogs/Duseniella patagonica/27.jpeg',
      'assets/images/Catalogs/Duseniella patagonica/46.jpeg',
      'assets/images/Catalogs/Duseniella patagonica/47.jpeg',
    ],
    'Ephedra ochreata': [
      'assets/images/Catalogs/Ephedra ochreata/1.jpeg',
      'assets/images/Catalogs/Ephedra ochreata/34.jpeg',
      'assets/images/Catalogs/Ephedra ochreata/39.jpeg',
      'assets/images/Catalogs/Ephedra ochreata/IMG_20181213_160728.jpg',
      'assets/images/Catalogs/Ephedra ochreata/IMG_20221210_181028.jpg',
    ],
    'Erodium cicutarium': [
      'assets/images/Catalogs/Erodium cicutarum/IMG_20180824_125128.jpg',
      'assets/images/Catalogs/Erodium cicutarum/IMG_20180824_125130.jpg',
    ],
    'Euphorbia portulacoides': [
      'assets/images/Catalogs/Euphorbia colina/41.jpeg',
      'assets/images/Catalogs/Euphorbia colina/42.jpeg',
      'assets/images/Catalogs/Euphorbia colina/43.jpeg',
    ],
    'Fabiana patagonica': [
      'assets/images/Catalogs/Fabiana patagonica/IMG_20181021_153647.jpg',
      'assets/images/Catalogs/Fabiana patagonica/IMG_20221007_122124.jpg',
    ],
    'Frankenia patagonica': [
      'assets/images/Catalogs/Frankenia patagonica/81.jpeg',
      'assets/images/Catalogs/Frankenia patagonica/87.jpeg',
      'assets/images/Catalogs/Frankenia patagonica/IMG_20221209_174700.jpg',
    ],
    'Gilia crassifolia': [
      'assets/images/Catalogs/Gilia laciniata/IMG_20221007_104826.jpg',
    ],
    'Grindelia chiloensis': [
      'assets/images/Catalogs/Grindelia chiloensis/69.jpeg',
      'assets/images/Catalogs/Grindelia chiloensis/IMG_20180824_121246.jpg',
      'assets/images/Catalogs/Grindelia chiloensis/IMG_20180824_121723.jpg',
    ],
    'Hoffmannseggia trifoliata': [
      'assets/images/Catalogs/Hoffmannseggia trifoliata/9.jpeg',
      'assets/images/Catalogs/Hoffmannseggia trifoliata/IMG_20191114_120351.jpg',
      'assets/images/Catalogs/Hoffmannseggia trifoliata/IMG_20220830_174345.jpg',
      'assets/images/Catalogs/Hoffmannseggia trifoliata/IMG_20220830_174401.jpg',
    ],
    'Lycium ameghinoi': [
      'assets/images/Catalogs/Lycium ameghinoi/28.jpeg',
      'assets/images/Catalogs/Lycium ameghinoi/65.jpeg',
      'assets/images/Catalogs/Lycium ameghinoi/IMG_20220830_171151.jpg',
      'assets/images/Catalogs/Lycium ameghinoi/IMG_20220830_171202.jpg',
      'assets/images/Catalogs/Lycium ameghinoi/IMG_20220830_174114.jpg',
    ],
    'Lycium chilense': [
      'assets/images/Catalogs/Lycium chilense/IMG_20220830_172155.jpg',
      'assets/images/Catalogs/Lycium chilense/IMG_20220830_172221.jpg',
      'assets/images/Catalogs/Lycium chilense/yaoyín 1.jpg',
    ],
    'Maihuenia patagonica': [
      'assets/images/Catalogs/Maihuenia patagonica/IMG_20231114_185155.jpg',
      'assets/images/Catalogs/Maihuenia patagonica/IMG_20231116_175029.jpg',
      'assets/images/Catalogs/Maihuenia patagonica/IMG_20231116_175044.jpg',
    ],
    'Maihueniopsis darwinii': [
      'assets/images/Catalogs/Maihueniopsis darwinii/38.jpeg',
      'assets/images/Catalogs/Maihueniopsis darwinii/IMG-20221116-WA0034.jpg',
    ],
    'Menodora robusta': [
      'assets/images/Catalogs/Menodora robusta/26.jpeg',
      'assets/images/Catalogs/Menodora robusta/52.jpeg',
      'assets/images/Catalogs/Menodora robusta/53.jpeg',
      'assets/images/Catalogs/Menodora robusta/74.jpeg',
    ],
    'Mulguraea ligustrina': [
      'assets/images/Catalogs/Mulguraea ligustrina/IMG_20181021_151951.jpg',
    ],
    'Mutisia retrorsa': [
      'assets/images/Catalogs/Mutisia retrorsa/71.jpeg',
      'assets/images/Catalogs/Mutisia retrorsa/72.jpeg',
      'assets/images/Catalogs/Mutisia retrorsa/83.jpeg',
      'assets/images/Catalogs/Mutisia retrorsa/84.jpeg',
      'assets/images/Catalogs/Mutisia retrorsa/IMG_20221116_115316.jpg',
      'assets/images/Catalogs/Mutisia retrorsa/IMG_20221210_181355.jpg',
    ],
    'Nassauvia ulicina': [
      'assets/images/Catalogs/Nassauvia ulicina/IMG_20181021_153925.jpg',
      'assets/images/Catalogs/Nassauvia ulicina/IMG_20221121_114901.jpg',
      'assets/images/Catalogs/Nassauvia ulicina/WhatsApp Image 2023-10-10 at 19.01.26 (1).jpeg',
    ],
    'Neltuma denudans': [
      'assets/images/Catalogs/Neltuma denudans/IMG_20221121_115011.jpg',
      'assets/images/Catalogs/Neltuma denudans/IMG_20221121_115629 - copia.jpg',
      'assets/images/Catalogs/Neltuma denudans/WhatsApp Image 2023-10-10 at 19.01.24.jpeg',
    ],
    'Oenothera odorata': [
      'assets/images/Catalogs/Oenothera odorata/IMG_20181213_125845.jpg',
    ],
    'Olsynium junceum': [
      'assets/images/Catalogs/Olsynium junceum/13.jpeg',
      'assets/images/Catalogs/Olsynium junceum/IMG_20221007_110829.jpg',
    ],
    'Orobanches sp': ['assets/images/Catalogs/Orobanches sp/29.jpeg'],
    'Pappostipa humilis': [
      'assets/images/Catalogs/Pappostipa humilis/IMG_20221210_181010.jpg',
    ],
    'Pappostipa neaei': [
      'assets/images/Catalogs/Pappostipa neaei/WhatsApp Image 2023-10-10 at 19.01.24 (1).jpeg',
    ],
    'Pappostipa speciosa': [
      'assets/images/Catalogs/Pappostipa speciosa/86.jpeg',
      'assets/images/Catalogs/Pappostipa speciosa/DSCN1783.JPG',
    ],
    'Perezia recurvata': [
      'assets/images/Catalogs/Perezia recurvata/73.jpeg',
      'assets/images/Catalogs/Perezia recurvata/WhatsApp Image 2023-10-10 at 19.01.23.jpeg',
    ],
    'Phacelia secunda': [
      'assets/images/Catalogs/Phacelia secunda/IMG_20181021_151340.jpg',
      'assets/images/Catalogs/Phacelia secunda/IMG_20181021_153622.jpg',
      'assets/images/Catalogs/Phacelia secunda/IMG_20221007_113919.jpg',
    ],
    'Pinnasa bergii': [
      'assets/images/Catalogs/Pinnasa bergii/48.jpeg',
      'assets/images/Catalogs/Pinnasa bergii/IMG_20181021_152729.jpg',
    ],
    'Pleurophora patagonica': [
      'assets/images/Catalogs/Pleurophora patagonica/32.jpeg',
      'assets/images/Catalogs/Pleurophora patagonica/IMG_20221210_181143.jpg',
      'assets/images/Catalogs/Pleurophora patagonica/WhatsApp Image 2023-10-10 at 18.58.59 (1).jpeg',
    ],
    'Poa ligularis': [
      'assets/images/Catalogs/Poa ligularis/DSCN1639.JPG',
      'assets/images/Catalogs/Poa ligularis/DSC_0319.JPG',
      'assets/images/Catalogs/Poa ligularis/IMG_20241119_153726.jpg',
    ],
    'Pterocactus hickenii': [
      'assets/images/Catalogs/Pterocactus hickenii/IMG_20221121_110842.jpg',
      'assets/images/Catalogs/Pterocactus hickenii/IMG_20231209_133957.jpg',
      'assets/images/Catalogs/Pterocactus hickenii/WhatsApp Image 2025-11-19 at 10.08.00 (1).jpeg',
    ],
    'Retanilla patagonica': [
      'assets/images/Catalogs/Retanilla patagonica/15.jpeg',
      'assets/images/Catalogs/Retanilla patagonica/18.jpeg',
      'assets/images/Catalogs/Retanilla patagonica/19.jpeg',
      'assets/images/Catalogs/Retanilla patagonica/56.jpeg',
      'assets/images/Catalogs/Retanilla patagonica/IMG_20180919_122529.jpg',
      'assets/images/Catalogs/Retanilla patagonica/IMG_20220830_152826.jpg',
      'assets/images/Catalogs/Retanilla patagonica/IMG_20221007_110130.jpg',
      'assets/images/Catalogs/Retanilla patagonica/IMG_20221007_122704.jpg',
      'assets/images/Catalogs/Retanilla patagonica/IMG_20221116_113254.jpg',
    ],
    'Schinus johnstonii': [
      'assets/images/Catalogs/Schinus johnstonii/2.jpeg',
      'assets/images/Catalogs/Schinus johnstonii/3.jpeg',
      'assets/images/Catalogs/Schinus johnstonii/57.jpeg',
      'assets/images/Catalogs/Schinus johnstonii/58.jpeg',
    ],
    'Senecio filaginoides': [
      'assets/images/Catalogs/Senecio filaginoides/DSCN1789.JPG',
      'assets/images/Catalogs/Senecio filaginoides/IMG_20231209_134650.jpg',
      'assets/images/Catalogs/Senecio filaginoides/IMG_20231209_140241.jpg',
      'assets/images/Catalogs/Senecio filaginoides/IMG_20231210_162254.jpg',
      'assets/images/Catalogs/Senecio filaginoides/IMG_20231210_162310.jpg',
      'assets/images/Catalogs/Senecio filaginoides/WhatsApp Image 2025-11-19 at 10.07.55.jpeg',
    ],
    'Sibara tehuelches': [
      'assets/images/Catalogs/Sibara tehuelches/35.jpeg',
      'assets/images/Catalogs/Sibara tehuelches/64.jpeg',
    ],
    'Tetraglochin alatum': [
      'assets/images/Catalogs/Tetraglochin alatum/49.jpeg',
      'assets/images/Catalogs/Tetraglochin alatum/51.jpeg',
    ],
    'Tetraglochin caespitosa': [
      'assets/images/Catalogs/Tetraglochin caespitosa/24.jpeg',
      'assets/images/Catalogs/Tetraglochin caespitosa/25.jpeg',
    ],
    'Tristagma nivale': [
      'assets/images/Catalogs/Tristagma nivale/76.jpeg',
      'assets/images/Catalogs/Tristagma nivale/IMG_20220830_162539.jpg',
      'assets/images/Catalogs/Tristagma nivale/WhatsApp Image 2023-10-10 at 19.01.26.jpeg',
    ],
    'Tristagma patagonicum': [
      'assets/images/Catalogs/Tristagma patagonicum/IMG_20181021_151145.jpg',
      'assets/images/Catalogs/Tristagma patagonicum/WhatsApp Image 2025-11-19 at 10.07.39 (1).jpeg',
    ],
    'Troncosoa seriphioides': [
      'assets/images/Catalogs/Troncosoa seriphioides/WhatsApp Image 2023-10-10 at 19.01.24 (2).jpeg',
    ],
    'Tropaeolum porifolium': [
      'assets/images/Catalogs/Tropaeolum porifolium/67.jpeg',
      'assets/images/Catalogs/Tropaeolum porifolium/77.jpeg',
      'assets/images/Catalogs/Tropaeolum porifolium/IMG_20220830_160913.jpg',
    ],
  };
}
