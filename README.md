é uma ferramenta de gerenciamento de finanças pessoais gratuita e de código aberto.

O objetivo deste projeto é criar uma alternativa FOSS estável para [Xero Personal](https://www.xero.com/personal/)
que foi [desligado](http://blog.xero.com/2013/08/winding-down-xero-personal-in-november-2014/) em novembro de 2014.

## Configurar

requer:

- [PostgreSQL](https://www.postgresql.org/) (Testado com 9.6)
- [Ruby](https://www.ruby-lang.org/) (Testado com 2.3)
- [RubyGems](https://rubygems.org/)
- [Ruby on Rails](http://rubyonrails.org/)
- [Pacote](https://bundler.io/)
- [Git](https://git-scm.com/)

As etapas básicas de configuração são:

- `cd dotledger`
- `cp config/database.yml.example config/database.yml`

Você terá que modificar o nome de usuário e a senha do postgres em `config/database.yml`.

- `instalação do pacote`
- `bundle exec rake db:setup`
- `bundle exec rails server`

## Testes

### Execute todos os testes

```
bundle exec rake spec spec: javascript
```

### Executar testes ruby ​​​​([RSpec](http://rspec.info/))

```
especificação de rake executivo do pacote
```

### Execute testes de javascript ([Jasmine](http://jasmine.github.io/))

```
pacote exec rake spec: javascript
```

## Licença

Copyright 2013 - 2018, Kale Worsley, BitBot Limited.

Dot Ledger é disponibilizado sob a Licença Apache, Versão 2.0. Consulte [LICENÇA](LICENÇA) para obter detalhes.