# ESTRUTURA DE PASTAS DO PROJETO
## Sistema de Planejamento para Vestibulares

---

## 1. ÁRVORE DE DIRETÓRIOS COMPLETA

```
projeto-vestibular/
│
├── public/                                    # Raiz pública do servidor web
│   ├── index.php                             # Roteador principal (entry point)
│   ├── .htaccess                             # Rewrite rules (Apache)
│   │
│   ├── css/
│   │   ├── bootstrap.min.css                 # Bootstrap 5
│   │   ├── style.css                         # Estilos customizados
│   │   ├── dashboard.css                     # Estilos do dashboard
│   │   ├── responsive.css                    # Media queries
│   │   └── variables.css                     # Cores e temas
│   │
│   ├── js/
│   │   ├── bootstrap.bundle.min.js           # Bootstrap JS
│   │   ├── chart.min.js                      # Chart.js
│   │   ├── app.js                            # App principal JS
│   │   ├── api.js                            # Funções AJAX/Fetch
│   │   ├── auth.js                           # Autenticação JS
│   │   ├── dashboard.js                      # Gráficos e dashboard
│   │   ├── scheduler.js                      # Motor de cronograma (frontend)
│   │   ├── form-validation.js                # Validação de formulários
│   │   └── utils.js                          # Funções utilitárias
│   │
│   ├── images/
│   │   ├── logo.png
│   │   ├── favicon.ico
│   │   ├── icons/
│   │   │   ├── book.svg
│   │   │   ├── calendar.svg
│   │   │   └── ...
│   │   └── illustrations/
│   │       └── ...
│   │
│   └── uploads/                              # Uploads de redações/arquivos
│       └── .gitkeep
│
├── app/                                       # Lógica da aplicação
│   │
│   ├── controllers/                          # Controllers (MVC)
│   │   ├── AuthController.php
│   │   ├── DashboardController.php
│   │   ├── CronogramaController.php
│   │   ├── MateriaController.php
│   │   ├── TopicoController.php
│   │   ├── RedacaoController.php
│   │   ├── SimuladoController.php
│   │   ├── RevisaoController.php
│   │   ├── ErroController.php
│   │   ├── UserController.php
│   │   └── BaseController.php                # Classe base para controllers
│   │
│   ├── models/                               # Models (Camada de dados)
│   │   ├── User.php
│   │   ├── Vestibular.php
│   │   ├── Materia.php
│   │   ├── Topico.php
│   │   ├── Cronograma.php
│   │   ├── CronogramaItem.php
│   │   ├── Redacao.php
│   │   ├── Simulado.php
│   │   ├── Revisao.php
│   │   ├── Erro.php
│   │   ├── Desempenho.php
│   │   └── BaseModel.php                     # Classe base para models
│   │
│   ├── services/                             # Serviços (Lógica de negócio)
│   │   ├── AuthService.php
│   │   ├── SchedulerService.php              # Motor de cronograma
│   │   ├── PriorizationService.php           # Algoritmo de priorização
│   │   ├── AnalyticsService.php              # Cálculos e análises
│   │   ├── EmailService.php
│   │   ├── ValidationService.php
│   │   └── SecurityService.php
│   │
│   ├── middleware/                           # Middlewares
│   │   ├── AuthMiddleware.php                # Verifica autenticação
│   │   ├── CsrfMiddleware.php                # CSRF protection
│   │   ├── ValidateMiddleware.php            # Validação de dados
│   │   ├── ErrorHandlerMiddleware.php
│   │   └── RateLimitMiddleware.php
│   │
│   ├── views/                                # Views (Templates HTML)
│   │   ├── layouts/
│   │   │   ├── base.php                      # Template base
│   │   │   ├── header.php
│   │   │   ├── footer.php
│   │   │   ├── navbar.php
│   │   │   └── sidebar.php
│   │   │
│   │   ├── auth/
│   │   │   ├── login.php
│   │   │   ├── register.php
│   │   │   ├── forgot-password.php
│   │   │   └── reset-password.php
│   │   │
│   │   ├── dashboard/
│   │   │   ├── index.php
│   │   │   ├── stats.php
│   │   │   ├── charts.php
│   │   │   └── overview.php
│   │   │
│   │   ├── cronograma/
│   │   │   ├── index.php
│   │   │   ├── criar.php
│   │   │   ├── editar.php
│   │   │   ├── visualizar.php
│   │   │   ├── semana.php
│   │   │   └── dia.php
│   │   │
│   │   ├── materias/
│   │   │   ├── index.php
│   │   │   ├── topicos.php
│   │   │   └── topico-detalhes.php
│   │   │
│   │   ├── redacoes/
│   │   │   ├── index.php
│   │   │   ├── enviar.php
│   │   │   ├── detalhes.php
│   │   │   └── evolucao.php
│   │   │
│   │   ├── simulados/
│   │   │   ├── index.php
│   │   │   ├── registrar.php
│   │   │   ├── detalhes.php
│   │   │   └── analise.php
│   │   │
│   │   ├── revisoes/
│   │   │   ├── index.php
│   │   │   └── pendentes.php
│   │   │
│   │   ├── erros/
│   │   │   ├── index.php
│   │   │   ├── criticos.php
│   │   │   └── analise.php
│   │   │
│   │   ├── user/
│   │   │   ├── profile.php
│   │   │   ├── settings.php
│   │   │   └── edit.php
│   │   │
│   │   └── errors/
│   │       ├── 404.php
│   │       └── 500.php
│   │
│   ├── helpers/                              # Funções auxiliares
│   │   ├── functions.php                     # Funções gerais
│   │   ├── date-helper.php                   # Manipulação de datas
│   │   ├── number-helper.php                 # Formatação de números
│   │   ├── string-helper.php                 # Manipulação de strings
│   │   └── validation-helper.php             # Validações comuns
│   │
│   └── exceptions/                           # Exceções customizadas
│       ├── AuthException.php
│       ├── ValidationException.php
│       ├── DatabaseException.php
│       └── NotFoundException.php
│
├── config/                                    # Configuração da aplicação
│   ├── app.php                               # Configurações gerais
│   ├── database.php                          # Conexão com BD
│   ├── constants.php                         # Constantes do sistema
│   ├── routes.php                            # Rotas da aplicação
│   └── security.php                          # Configurações de segurança
│
├── database/                                  # Banco de dados
│   ├── migrations.sql                        # Script para criar tabelas
│   ├── seeders.sql                           # Dados iniciais
│   ├── backup/
│   │   └── backup_2024_xx_xx.sql
│   └── queries/                              # Queries úteis
│       ├── analytics.sql
│       └── reports.sql
│
├── vendor/                                    # Dependências do Composer
│   └── ...
│
├── logs/                                      # Logs do sistema
│   ├── error.log
│   ├── access.log
│   ├── auth.log
│   └── database.log
│
├── tests/                                     # Testes automatizados
│   ├── Unit/
│   │   ├── AuthServiceTest.php
│   │   ├── SchedulerServiceTest.php
│   │   └── ValidationTest.php
│   │
│   ├── Feature/
│   │   ├── AuthTest.php
│   │   ├── CronogramaTest.php
│   │   └── RedacaoTest.php
│   │
│   └── bootstrap.php                         # Setup dos testes
│
├── docs/                                      # Documentação
│   ├── API.md                                # Documentação da API
│   ├── SETUP.md                              # Setup do projeto
│   ├── ARCHITECTURE.md                       # Arquitetura detalhada
│   ├── DATABASE.md                           # Schema do BD
│   ├── DEVELOPER.md                          # Guia para desenvolvedores
│   └── USER_GUIDE.md                         # Guia do usuário
│
├── .env.example                              # Exemplo de variáveis de ambiente
├── .env                                      # Variáveis de ambiente (NÃO commitá-lo)
├── .gitignore                                # Arquivos ignorados pelo Git
├── .htaccess                                 # Rewrite rules Apache (root)
├── composer.json                             # Dependências PHP
├── composer.lock                             # Lock de dependências
├── README.md                                 # Documentação principal
├── LICENSE                                   # Licença do projeto
└── CHANGELOG.md                              # Histórico de versões

```

---

## 2. DESCRIÇÃO DETALHADA POR PASTA

### 📂 **public/** - Raiz do Servidor Web
```
Tudo o que é acessível publicamente deve estar aqui.
Contém:
- index.php (roteador principal)
- CSS e JavaScript
- Imagens públicas
- Uploads de usuários

⚠️ Segurança: Nunca coloque .env ou arquivos sensíveis aqui
```

### 📂 **app/controllers/** - Controllers (MVC Pattern)
```
Responsáveis por:
- Receber requisições HTTP
- Orquestrar serviços
- Retornar respostas (JSON ou HTML)

Exemplo: CronogramaController.php
- GET  /cronograma         → index()
- GET  /cronograma/criar   → create()
- POST /cronograma         → store()
- GET  /cronograma/:id     → show()
- PUT  /cronograma/:id     → update()
- DELETE /cronograma/:id   → destroy()
```

### 📂 **app/models/** - Models (Camada de Dados)
```
Responsáveis por:
- Mapear tabelas do BD
- Queries diretas
- Validações em nível de BD
- Relacionamentos entre entidades

Exemplo: User.php
- Propriedades: $id, $email, $name, etc
- Métodos: findById(), save(), delete(), etc
```

### 📂 **app/services/** - Services (Lógica de Negócio)
```
Responsáveis por:
- Regras de negócio complexas
- Orquestração entre múltiplos models
- Cálculos e algoritmos

Exemplo: SchedulerService.php
- Gerar cronograma inteligente
- Calcular prioridades
- Alocar horas por matéria
```

### 📂 **app/middleware/** - Middlewares (Pipeline)
```
Responsáveis por:
- Validar requisições
- Proteger rotas
- CSRF protection
- Rate limiting
- Logging

Fluxo: Requisição → Middleware → Controller → Resposta
```

### 📂 **app/views/** - Views (Templates HTML)
```
Arquivos .php com HTML puro
Contem:
- Templates para cada página
- Componentes reutilizáveis (header, footer)
- Loops e condicionais do PHP

NÃO fazer lógica complexa aqui!
```

### 📂 **config/** - Configurações
```
Arquivo único de configuração por tema:
- database.php  → Conexão com BD
- app.php       → Configurações gerais
- routes.php    → Mapeamento de rotas
- security.php  → Headers de segurança
```

### 📂 **database/** - Scripts SQL
```
migrations.sql  → Criar tabelas
seeders.sql     → Dados iniciais
backup/         → Backups do BD
queries/        → Queries úteis
```

---

## 3. ARQUIVO: .env (Exemplo)

```env
# Configuração da Aplicação
APP_NAME="Sistema de Planejamento Vestibulares"
APP_ENV="development"  # development | production
APP_DEBUG=true
APP_URL="http://localhost:8000"

# Banco de Dados
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=vestibulares_db
DB_USERNAME=root
DB_PASSWORD=

# Segurança
SESSION_TIMEOUT=1800
CSRF_TOKEN_LENGTH=32
PASSWORD_HASH_ALGORITHM=bcrypt

# Email (para recuperação de senha)
MAIL_DRIVER=smtp
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=seu_email@example.com
MAIL_PASSWORD=sua_senha
MAIL_FROM_ADDRESS=noreply@vestibulares.com

# Uploads
UPLOAD_MAX_SIZE=5242880  # 5MB em bytes
UPLOAD_PATH="public/uploads/"

# Logging
LOG_LEVEL=debug
LOG_PATH="logs/"
```

---

## 4. ARQUIVO: composer.json (Dependências)

```json
{
    "name": "seu-nome/sistema-vestibulares",
    "description": "Sistema inteligente de planejamento para vestibulares",
    "type": "project",
    "license": "MIT",
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Config\\": "config/",
            "Database\\": "database/"
        },
        "files": ["app/helpers/functions.php"]
    },
    "require": {
        "php": ">=8.0",
        "ext-json": "*",
        "ext-pdo": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "^9.5",
        "squizlabs/php_codesniffer": "^3.6"
    }
}
```

---

## 5. ARQUIVO: .gitignore

```
# Variáveis de ambiente
.env
.env.local

# Dependências
/vendor
composer.lock

# Logs
logs/
*.log

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Uploads
public/uploads/*
!public/uploads/.gitkeep

# Cache
/tmp
/cache

# Testes
/tests/coverage
```

---

## 6. ARQUIVO: .htaccess (Rewrite Rules)

```apache
# Ativar mod_rewrite
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    # Remover "public" da URL (se aplicável)
    RewriteCond %{REQUEST_URI} !^public/
    RewriteRule ^(.*)$ public/$1 [L]
    
    # Redirecionar todas as requisições para index.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php?route=$1 [QSA,L]
</IfModule>
```

---

## 7. ESTRUTURA DE ROUTES (config/routes.php)

```php
<?php
return [
    // Autenticação (públicas)
    'GET'  => '/login'                  => 'AuthController@login',
    'POST' => '/login'                  => 'AuthController@handleLogin',
    'GET'  => '/register'               => 'AuthController@register',
    'POST' => '/register'               => 'AuthController@handleRegister',
    'GET'  => '/forgot-password'        => 'AuthController@forgotPassword',
    
    // Dashboard (autenticadas)
    'GET'  => '/dashboard'              => 'DashboardController@index',
    'GET'  => '/dashboard/stats'        => 'DashboardController@stats',
    
    // Cronograma
    'GET'  => '/cronograma'             => 'CronogramaController@index',
    'POST' => '/cronograma'             => 'CronogramaController@store',
    'POST' => '/cronograma/gerar'       => 'CronogramaController@gerar',
    'GET'  => '/cronograma/:id'         => 'CronogramaController@show',
    'PUT'  => '/cronograma/:id'         => 'CronogramaController@update',
    
    // Redações
    'GET'  => '/redacoes'               => 'RedacaoController@index',
    'POST' => '/redacoes'               => 'RedacaoController@store',
    'GET'  => '/redacoes/:id'           => 'RedacaoController@show',
    
    // API Endpoints
    'GET'  => '/api/cronograma'         => 'ApiCronogramaController@index',
    'POST' => '/api/redacoes'           => 'ApiRedacaoController@store',
    // ... mais rotas
];
```

---

## 8. CONVENÇÕES DE NOMENCLATURA

### Classes
```php
// Controllers
class DashboardController {}
class CronogramaController {}

// Models
class User {}
class Cronograma {}

// Services
class SchedulerService {}
class PriorizationService {}
```

### Arquivos
```
DashboardController.php  (PascalCase + tipo)
user-profile.php         (kebab-case para views)
form-validation.js       (kebab-case para JS)
```

### Funções/Métodos
```php
function getUserById() {}           // camelCase
function calculateSchedule() {}
function updateUserStatus() {}
```

### Constantes
```php
define('DB_HOST', 'localhost');
define('MAX_LOGIN_ATTEMPTS', 5);
define('SESSION_TIMEOUT', 1800);
```

---

## 9. CHECKLIST DE SETUP

- [ ] Clonar repositório
- [ ] Copiar `.env.example` para `.env`
- [ ] Instalar dependências: `composer install`
- [ ] Criar banco de dados: `mysql -u root < database/migrations.sql`
- [ ] Configurar `.env` com dados do BD
- [ ] Criar pastas de logs e uploads
- [ ] Configurar permissões de escrita (logs/, uploads/)
- [ ] Testar servidor: `php -S localhost:8000 -t public/`
- [ ] Acessar: http://localhost:8000

---

## 10. ESTRUTURA DE PASTAS PARA DADOS DINÂMICOS

```
logs/
├── error.log           # Erros do PHP
├── access.log          # Requisições HTTP
├── auth.log            # Login/logout
└── database.log        # Queries lentas

public/uploads/
├── redacoes/           # Textos de redações
├── temp/               # Arquivos temporários
└── .gitkeep            # Garante que a pasta exista no git
```

---

**Versão:** 1.0  
**Atualizado:** Junho 2026  
**Total de arquivos principais:** 50+
