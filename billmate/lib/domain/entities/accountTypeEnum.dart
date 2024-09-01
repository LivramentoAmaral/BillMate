enum AccountTypeEnum {
  Prime,
  Simple,
  Unknown; // Adicionado para lidar com valores inesperados

  static AccountTypeEnum fromString(String accountType) {
    switch (accountType) {
      case 'Prime':
        return AccountTypeEnum.Prime;
      case 'Simple':
        return AccountTypeEnum.Simple;
      default:
        return AccountTypeEnum
            .Unknown; // Retorna um valor padrão se o tipo for desconhecido
    }
  }

  String get value {
    switch (this) {
      case AccountTypeEnum.Prime:
        return 'Prime';
      case AccountTypeEnum.Simple:
        return 'Basic';
      default:
        return 'Unknown'; // Valor padrão para segurança
    }
  }
}
