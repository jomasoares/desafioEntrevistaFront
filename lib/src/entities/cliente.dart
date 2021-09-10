class Cliente {
  int? id;
  String razaoSocial;
  String cnpj;
  String regimeTributario;
  String email;

  Cliente(this.razaoSocial, this.cnpj, this.regimeTributario, this.email);

  String get regime {
    if (regimeTributario == 'SIMPLES_NACIONAL') {
      return 'Simples Nacional';
    } else if (regimeTributario == 'LUCRO_PRESUMIDO') {
      return 'Lucro Presumido';
    }
    return 'ERROR';
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    Cliente novoCliente = Cliente(
      json['razaoSocial'],
      json['cnpj'],
      json['regimeTributario'],
      json['email'],
    );
    novoCliente.id = json['id'];
    return novoCliente;
  }

  Map<String, dynamic> toJson() => {
        "razaoSocial": razaoSocial,
        "cnpj": cnpj,
        "regimeTributario": regimeTributario,
        "email": email
      };
}
