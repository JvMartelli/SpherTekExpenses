# Spher Tek Expenses 

Aplicativo mobile de controle de despesas corporativas desenvolvido em Flutter como trabalho de conclusão de matéria.

---

## Sobre o Projeto

O **Spher Tek Expenses** é um sistema de controle de despesas voltado para empresas que possuem equipes externas, como motoristas e vendedores. O aplicativo permite o registro de despesas com foto do comprovante, funcionando de forma simples e prática diretamente pelo celular.

---

## Funcionalidades

- ✅ Login com autenticação de usuário
- ✅ Listagem de despesas cadastradas
- ✅ Cadastro de nova despesa com foto do comprovante
- ✅ Uso da câmera do dispositivo como sensor
- ✅ Visualização detalhada de cada despesa
- ✅ Exclusão de despesas com confirmação
- ✅ Armazenamento local dos dados
- ✅ Compatível com Android e Web

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada do app
├── model/
│   └── despesa.dart                   # Classe modelo da despesa
├── database/
│   └── database_helper.dart           # Gerenciamento do banco local
└── pages/
    ├── login_page.dart                # Tela 1 - Login
    ├── lista_despesas_page.dart       # Tela 2 - Lista de despesas
    ├── nova_despesa_page.dart         # Tela 3 - Nova despesa + câmera
    └── detalhe_despesa_page.dart      # Tela 4 - Detalhe da despesa
```

---

## Tecnologias Utilizadas

| Tecnologia | Uso |
|---|---|
| Flutter | Framework principal |
| Dart | Linguagem de programação |
| shared_preferences | Banco de dados local |
| image_picker | Acesso à câmera do dispositivo |
| intl | Formatação de datas e moeda |

---

## Sensor Utilizado

O aplicativo utiliza a **câmera do dispositivo** como sensor, acessada através do pacote `image_picker`. A câmera é usada para fotografar o comprovante da despesa no momento do lançamento.

```dart
final picked = await picker.pickImage(
  source: ImageSource.camera,
  imageQuality: 75,
);
```

---

## Armazenamento de Dados

Os dados são armazenados localmente no dispositivo usando **SharedPreferences**, no formato JSON. O padrão **Singleton** é utilizado no `DatabaseHelper` para garantir uma única instância de acesso aos dados.

```dart
static final DatabaseHelper _instance = DatabaseHelper._interno();
factory DatabaseHelper() => _instance;
```

---

### Pré-requisitos
- Flutter SDK 3.x ou superior
- Android Studio
- Dispositivo Android ou emulador


---

## Usuário de Demonstração

| Campo | Valor |
|---|---|
| E-mail | motorista@spher.com |
| Senha | 123456 |

---

## Arquitetura

O projeto segue uma arquitetura simples em camadas:

- **Model** → representa os dados (Despesa)
- **Database** → acesso e persistência dos dados (DatabaseHelper)
- **Pages** → interface e lógica de cada tela

