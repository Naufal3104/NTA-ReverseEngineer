/// Info tampilan satu tipe prajurit — dipakai modal Armies / Barracks /
/// tile-garrison. Nama & jenis senjata diambil dari `GameData.troops` agar
/// konsisten dengan tabel statistik (SoldierAttribute.md).
class TroopInfo {
  const TroopInfo({
    required this.id,
    required this.name,
    required this.weapon,
    required this.counter,
  });

  final String id;
  final String name;
  final String weapon;
  final String counter;
}

class TroopCatalog {
  TroopCatalog._();

  /// Nama tampilan + jenis senjata (spear / shield / bow / horse) untuk
  /// ikon kecil di modal Armies. Sengaja hard-coded — data asli ada di
  /// `game_data.dart` tetapi bentuknya map generik.
  static const Map<String, TroopInfo> _info = {
    'longspearman': TroopInfo(
      id: 'longspearman',
      name: 'Longspearman',
      weapon: 'spear',
      counter: 'Cavalry',
    ),
    'twin_spearman': TroopInfo(
      id: 'twin_spearman',
      name: 'Twin Spearman',
      weapon: 'spear',
      counter: 'Cavalry',
    ),
    'longbowman': TroopInfo(
      id: 'longbowman',
      name: 'Longbowman',
      weapon: 'bow',
      counter: 'Spearman',
    ),
    'crossbowman': TroopInfo(
      id: 'crossbowman',
      name: 'Crossbowman',
      weapon: 'bow',
      counter: 'Spearman',
    ),
    'saber_shield': TroopInfo(
      id: 'saber_shield',
      name: 'Saber & Shield',
      weapon: 'shield',
      counter: 'Bowman',
    ),
    'sword_shield': TroopInfo(
      id: 'sword_shield',
      name: 'Sword & Shield',
      weapon: 'shield',
      counter: 'Bowman',
    ),
    'sword_cavalry': TroopInfo(
      id: 'sword_cavalry',
      name: 'Sword Cavalry',
      weapon: 'horse',
      counter: 'Shield Soldier',
    ),
    'cavalry_archer': TroopInfo(
      id: 'cavalry_archer',
      name: 'Cavalry Archer',
      weapon: 'horse',
      counter: 'Shield Soldier',
    ),
  };

  /// Nama tampilan tipe prajurit; fallback ke id kalau tidak dikenal.
  static String nameOf(String troopId) {
    return _info[troopId]?.name ?? troopId;
  }

  /// Singkatan 2 huruf untuk ikon kecil (mis. `SP`, `BW`, `SD`, `CV`).
  static String shortOf(String troopId) {
    switch (_info[troopId]?.weapon) {
      case 'spear':
        return 'SP';
      case 'bow':
        return 'BW';
      case 'shield':
        return 'SD';
      case 'horse':
        return 'CV';
      default:
        return troopId.length >= 2
            ? troopId.substring(0, 2).toUpperCase()
            : troopId.toUpperCase();
    }
  }

  /// Counter pasif: 'Cavalry' / 'Bowman' / 'Spearman' / 'Shield Soldier'.
  static String counterOf(String troopId) =>
      _info[troopId]?.counter ?? '—';
}
