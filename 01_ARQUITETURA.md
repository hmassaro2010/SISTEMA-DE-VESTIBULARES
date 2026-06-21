# ARQUITETURA DO SISTEMA DE PLANEJAMENTO PARA VESTIBULARES

## 1. VISÃO GERAL

**Tipo de Arquitetura:** MVC (Model-View-Controller)  
**Padrão:** RESTful API  
**Paradigma:** Orientado a Objetos  
**Stack:** PHP 8+ | MySQL 8 | JavaScript ES6+ | Bootstrap 5

---

## 2. COMPONENTES PRINCIPAIS

### Frontend Layer
- **Apresentação:** HTML5 + CSS3 + JavaScript ES6+
- **Framework UI:** Bootstrap 5
- **Gráficos:** Chart.js
- **Comunicação:** Fetch API / AJAX
- **Armazenamento Local:** LocalStorage para cache

### Backend Layer
- **Servidor:** PHP 8+ (Apache/Nginx)
- **Banco de Dados:** MySQL 8
- **API:** REST Endpoints
- **Autenticação:** JWT + Sessions
- **ORM:** Queries PreparedStatements (segurança)

### Arquitetura de Pastas
```
projeto-vestibular/
├── public/                    # Raiz web (index.php, assets)
│   ├── index.php             # Roteador principal
│   ├── css/                  # Estilos
│   ├── js/                   # Scripts frontend
│   ├── images/               # Imagens
│   └── uploads/              # Uploads de usuários
│
├── app/                      # Código da aplicação
│   ├── controllers/          # Controllers (lógica de requisição)
│   ├── models/              # Models (lógica de dados)
│   ├── views/               # Views (templates HTML)
│   ├── middleware/          # Middlewares (autenticação, validação)
│   ├── helpers/             # Funções auxiliares
│   └── services/            # Serviços (regras de negócio complexas)
│
├── config/                   # Configurações
│   ├── database.php         # Conexão com BD
│   ├── app.php              # Configurações da app
│   └── constants.php        # Constantes
│
├── database/                 # Scripts SQL
│   ├── migrations.sql       # Estrutura completa
│   ├── seeders.sql          # Dados iniciais
│   └── backup.sql           # Backup
│
├── vendor/                   # Dependências (Composer)
├── logs/                     # Logs do sistema
├── .env                      # Variáveis de ambiente
├── composer.json             # Dependências PHP
└── README.md                 # Documentação
```

---

## 3. FLUXO DE DADOS

```
┌─────────────────────────────────────────────────┐
│           CLIENTE (Frontend)                     │
│  HTML + CSS + JavaScript + Bootstrap 5         │
└────────────────────┬────────────────────────────┘
                     │ AJAX/Fetch
                     ▼
┌─────────────────────────────────────────────────┐
│         ROTEADOR (public/index.php)              │
│  Valida rota e dispara controller apropriado   │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│         MIDDLEWARE (Autenticação)                │
│  Verifica sessão, token JWT, permissões        │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│      CONTROLLER (app/controllers/)               │
│  Processa requisição, orquestra lógica          │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│    SERVICE/MODEL (app/models/)                   │
│  Regras de negócio, acesso ao BD                │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│    DATABASE (MySQL 8)                            │
│  Armazena dados persistentes                    │
└─────────────────────────────────────────────────┘
```

---

## 4. PADRÕES DE DESIGN

### MVC Estrito
```
Model   → Interage com banco de dados
View    → Renderiza a apresentação
Control → Orquestra modelo e view
```

### Service Layer
```
Controllers → Services → Models → Database
```

### Repository Pattern (Opcional, mas recomendado)
```
Controllers → Services → Repositories → Models → Database
```

### Middleware Pipeline
```
Request → Auth Middleware → Validation Middleware → Controller → Response
```

---

## 5. AUTENTICAÇÃO E SEGURANÇA

### Autenticação
- **Método:** Sessions + Password Hash (password_hash)
- **Recuperação:** Email com token temporário
- **Logout:** Destruição de sessão
- **Timeout:** 30 minutos de inatividade

### Segurança
- ✅ Prepared Statements (PDO) - Previne SQL Injection
- ✅ Password Hash - bcrypt com salt
- ✅ CSRF Tokens - Token único por formulário
- ✅ Input Validation - Whitelist de caracteres
- ✅ Output Escaping - Sanitização de HTML
- ✅ HTTPS - Recomendado em produção
- ✅ Rate Limiting - Limite de requisições
- ✅ Headers de Segurança - X-Frame-Options, Content-Security-Policy

---

## 6. ENDPOINTS DA API REST

### Autenticação
```
POST   /api/auth/register          - Cadastro
POST   /api/auth/login             - Login
POST   /api/auth/logout            - Logout
POST   /api/auth/forgot-password   - Recuperação de senha
POST   /api/auth/reset-password    - Reset de senha
GET    /api/auth/profile           - Perfil do usuário
PUT    /api/auth/profile           - Atualizar perfil
```

### Dashboard
```
GET    /api/dashboard              - Dados do dashboard
GET    /api/dashboard/stats        - Estatísticas gerais
```

### Cronograma
```
GET    /api/cronograma             - Listar cronograma
POST   /api/cronograma/gerar       - Gerar novo cronograma
PUT    /api/cronograma/:id         - Atualizar cronograma
DELETE /api/cronograma/:id         - Deletar cronograma
GET    /api/cronograma/semana      - Cronograma da semana
GET    /api/cronograma/dia/:data   - Cronograma do dia
```

### Conteúdos
```
GET    /api/materias               - Listar todas matérias
GET    /api/materias/:id           - Detalhes matéria
GET    /api/materias/:id/topicos   - Tópicos da matéria
GET    /api/topicos/:id            - Detalhes do tópico
```

### Revisões
```
GET    /api/revisoes               - Listar revisões pendentes
POST   /api/revisoes               - Agendar revisão
PUT    /api/revisoes/:id           - Marcar como concluída
```

### Redações
```
GET    /api/redacoes               - Listar redações
POST   /api/redacoes               - Enviar redação
GET    /api/redacoes/:id           - Detalhes redação
PUT    /api/redacoes/:id           - Registrar correção
```

### Simulados
```
GET    /api/simulados              - Listar simulados
POST   /api/simulados              - Registrar simulado
GET    /api/simulados/:id          - Detalhes simulado
```

### Banco de Erros
```
GET    /api/erros                  - Listar erros
POST   /api/erros                  - Registrar erro
GET    /api/erros/criticos         - Erros críticos
```

---

## 7. ESTRUTURA DE RESPONSE API

### Success Response
```json
{
  "status": "success",
  "code": 200,
  "message": "Operação realizada com sucesso",
  "data": { ... }
}
```

### Error Response
```json
{
  "status": "error",
  "code": 400,
  "message": "Descrição do erro",
  "errors": [
    {
      "field": "email",
      "message": "Email inválido"
    }
  ]
}
```

---

## 8. TRATAMENTO DE ERROS

| Código | Significado |
|--------|-------------|
| 200 | OK - Sucesso |
| 201 | Created - Recurso criado |
| 400 | Bad Request - Validação falhou |
| 401 | Unauthorized - Não autenticado |
| 403 | Forbidden - Sem permissão |
| 404 | Not Found - Recurso não existe |
| 500 | Server Error - Erro no servidor |

---

## 9. CICLO DE VIDA DE UMA REQUISIÇÃO

1. **Cliente envia requisição HTTP**
2. **Router captura a rota**
3. **Middleware verifica autenticação**
4. **Controller valida dados**
5. **Service aplica regras de negócio**
6. **Model interage com banco de dados**
7. **Response é formatada em JSON**
8. **Cliente recebe e atualiza a UI**

---

## 10. PADRÕES DE CÓDIGO

### Convenções de Nomenclatura
- **Classes:** PascalCase (UserController, StudentModel)
- **Métodos:** camelCase (getUserById, createSchedule)
- **Propriedades:** camelCase (userId, isActive)
- **Constantes:** UPPER_CASE (DB_HOST, MAX_LOGIN_ATTEMPTS)
- **Funções:** snake_case (get_user_id, create_schedule)

### Estrutura de Classe Model
```php
class User {
    private $id;
    private $email;
    private $name;
    
    // Getters e Setters
    public function getId() { return $this->id; }
    public function setId($id) { $this->id = $id; }
    
    // Métodos
    public static function findById($id) { ... }
    public function save() { ... }
    public function delete() { ... }
}
```

---

## 11. AMBIENTE DE DESENVOLVIMENTO

### Requisitos
- PHP 8.0+
- MySQL 8.0+
- Composer (Gerenciador de dependências PHP)
- Git
- IDE: VS Code + Extensões PHP/MySQL
- Ferramentas: Postman (API testing), PHPMyAdmin

### Setup Inicial
```bash
# Clonar repositório
git clone https://github.com/seu-repo/projeto-vestibular.git

# Instalar dependências
composer install

# Configurar .env
cp .env.example .env

# Criar banco de dados
mysql -u root < database/migrations.sql

# Iniciar servidor
php -S localhost:8000 -t public/
```

---

## 12. ROADMAP DE DESENVOLVIMENTO

- **Sprint 1:** Autenticação + Estrutura base
- **Sprint 2:** CRUD de conteúdos + Banco de dados
- **Sprint 3:** Motor de cronograma
- **Sprint 4:** Dashboard + Gráficos
- **Sprint 5:** Sistema de revisão + Redações
- **Sprint 6:** Simulados + Banco de erros
- **Sprint 7:** Testes + Otimização
- **Sprint 8:** Deploy + Documentação

---

## 13. MÉTRICAS E MONITORAMENTO

- **Performance:** Tempo de resposta < 200ms
- **Disponibilidade:** Uptime > 99.9%
- **Confiabilidade:** Zero SQL Injections
- **Escalabilidade:** Suportar 10.000+ usuários simultâneos

---

**Versão:** 1.0  
**Última atualização:** Junho 2026  
**Autor:** Arquiteto de Software Sênior
