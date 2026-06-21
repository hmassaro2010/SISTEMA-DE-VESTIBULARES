# 📊 GUIA VISUAL - ARQUITETURA DO SISTEMA
## Diagramas e Fluxogramas

---

## 1. ARQUITETURA DE CAMADAS

```
┌─────────────────────────────────────────────────────────┐
│                    CAMADA DE APRESENTAÇÃO                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   HTML5      │  │   CSS3       │  │  JavaScript  │   │
│  │              │  │  Bootstrap 5 │  │   ES6+       │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │ AJAX / Fetch API
┌──────────────────────▼──────────────────────────────────┐
│                   CAMADA DE ROTEAMENTO                  │
│  ┌────────────────────────────────────────────────────┐ │
│  │            public/index.php (Router)              │ │
│  │  Mapeia URL → Controller → Action                │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │ Route Dispatch
┌──────────────────────▼──────────────────────────────────┐
│                 MIDDLEWARE PIPELINE                      │
│  ┌─────────┐ ┌──────────┐ ┌────────────┐ ┌──────────┐  │
│  │  Auth   │→│  CSRF    │→│ Validation │→│  Error   │  │
│  │         │ │          │ │            │ │ Handler  │  │
│  └─────────┘ └──────────┘ └────────────┘ └──────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │ Request Processing
┌──────────────────────▼──────────────────────────────────┐
│               CAMADA DE APLICAÇÃO (MVC)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Controllers  │→ │   Services   │→ │   Models     │  │
│  │              │  │ (Business    │  │ (Data Access)│  │
│  │ - Recebem    │  │  Logic)      │  │              │  │
│  │ - Orquestram │  │              │  │ - Queries    │  │
│  │ - Respondem  │  │ - Algoritmos │  │ - Validação  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │ SQL Queries (Prepared Statements)
┌──────────────────────▼──────────────────────────────────┐
│              CAMADA DE PERSISTÊNCIA                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │           MySQL Database (PDO)                     │ │
│  │  15 Tabelas | 20+ Índices | 5 Views | 1 Trigger   │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 2. FLUXO DE UMA REQUISIÇÃO

```
1. CLIENTE
   │
   ├─ Digita URL: /cronograma
   ├─ Faz requisição GET/POST
   └─ Envia dados (JSON/Form)
      │
      ▼
2. NAVEGADOR
   │
   ├─ Resolve DNS
   ├─ Envia HTTP Request
   └─ Com headers e cookies
      │
      ▼
3. SERVIDOR (Apache/Nginx)
   │
   ├─ Recebe requisição
   ├─ Aplica rewrite rules (.htaccess)
   └─ Chama public/index.php
      │
      ▼
4. ROTEADOR (index.php)
   │
   ├─ Analisa URL
   ├─ Identifica rota
   ├─ Instancia Controller
   └─ Executa action
      │
      ▼
5. MIDDLEWARE
   │
   ├─ AuthMiddleware
   │  ├─ Verifica sessão
   │  └─ Bloqueia se não autenticado
   │
   ├─ CsrfMiddleware
   │  └─ Valida token CSRF
   │
   └─ ValidateMiddleware
      └─ Valida estrutura de dados
         │
         ▼
6. CONTROLLER
   │
   ├─ CronogramaController::index()
   ├─ Valida entrada
   ├─ Chama Service
   └─ Formata resposta
      │
      ▼
7. SERVICE
   │
   ├─ SchedulerService
   ├─ Aplica regras de negócio
   ├─ Chama Model
   └─ Retorna resultado
      │
      ▼
8. MODEL
   │
   ├─ Cronograma::findByUserId()
   ├─ Monta query SQL
   ├─ Usa Prepared Statement
   └─ Retorna objeto
      │
      ▼
9. DATABASE
   │
   ├─ MySQL recebe query
   ├─ Valida permissões
   ├─ Executa query
   └─ Retorna resultado
      │
      ▼
10. MODEL (Response)
    │
    ├─ Mapeia resultado para objeto
    └─ Retorna ao Controller
       │
       ▼
11. CONTROLLER (Response)
    │
    ├─ Para HTML: Renderiza view
    ├─ Para JSON: json_encode()
    └─ Define headers HTTP
       │
       ▼
12. SERVIDOR
    │
    ├─ Envia status code (200, 400, 500)
    ├─ Envia headers
    └─ Envia body (HTML/JSON)
       │
       ▼
13. NAVEGADOR
    │
    ├─ Recebe response
    ├─ Processa HTML/CSS
    ├─ Executa JavaScript
    └─ Renderiza página
       │
       ▼
14. USUÁRIO
    │
    └─ Vê página atualizada ✓
```

---

## 3. ESTRUTURA MVC VISUAL

```
                    REQUEST (URL)
                         │
                         ▼
                    ┌──────────┐
                    │ ROUTER   │
                    └────┬─────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
    ┌─────────┐    ┌──────────┐    ┌──────────┐
    │  VIEW   │◄───│CONTROLLER│───►│  MODEL   │
    │         │    │          │    │          │
    │ Template│    │ Lógica   │    │ Database │
    │ HTML    │    │ Requisição    │ Queries  │
    └────┬────┘    └──────────┘    └────┬─────┘
         │                              │
         └──────────────────────────────┘
                    │
                    ▼
              RESPONSE (HTML/JSON)
                    │
                    ▼
                 NAVEGADOR
```

---

## 4. CAMADAS DE SEGURANÇA

```
REQUEST
  │
  ├─ 1️⃣ HTTPS
  │   └─ Criptografia em trânsito
  │
  ├─ 2️⃣ CSRF TOKEN
  │   └─ Valida origem da requisição
  │
  ├─ 3️⃣ VALIDAÇÃO DE INPUT
  │   └─ Whitelist de caracteres
  │
  ├─ 4️⃣ PREPARED STATEMENTS
  │   └─ Impede SQL Injection
  │
  ├─ 5️⃣ SESSION SECURITY
  │   └─ Timeout de inatividade
  │
  └─ 6️⃣ OUTPUT ESCAPING
      └─ Previne XSS (htmlspecialchars)

        ✓ Requisição segura processada
```

---

## 5. MODELO DE DADOS (Simplificado)

```
┌──────────────┐
│  USUARIOS    │◄──────────────┐
├──────────────┤               │
│ id*          │               │
│ email        │               │
│ nome         │               │
│ senha (hash) │               │
└──────┬───────┘               │
       │                       │
       │ 1:N                   │
       │                       │
    ┌──▼──────────────┐   ┌────┴──────────┐
    │ VESTIBULARES    │   │ DESEMPENHO    │
    │                 │   │               │
    │ user_id (FK)◄───┴───┤ user_id (FK)  │
    │ data_prova      │   │               │
    │ curso           │   └───────────────┘
    └────┬────────────┘
         │ 1:N
         │
    ┌────▼──────────────┐
    │ CRONOGRAMA        │
    │                   │
    │ vestibular_id (FK)│
    │ user_id (FK)◄─────┴─ (relacionado)
    │ data_inicio       │
    │ data_fim          │
    └────┬──────────────┘
         │ 1:N
         │
    ┌────▼──────────────────┐
    │ CRONOGRAMA_ITEMS      │
    │                       │
    │ topico_id (FK)────────┐
    │ data_prevista         │ 1:N
    │ horas_alocadas        │
    └───────────────────────┘
                            │
                    ┌───────▼──────────┐
                    │ TOPICOS          │
                    │                  │
                    │ materia_id (FK)  │
                    │ dificuldade      │
                    │ peso_global      │
                    └────┬─────────────┘
                         │ 1:N
                         │
                    ┌────▼──────────┐
                    │ MATERIAS      │
                    │               │
                    │ nome          │
                    │ dificuldade   │
                    └───────────────┘
```

---

## 6. FLUXO DE GERAÇÃO DO CRONOGRAMA

```
USUÁRIO CLICA "GERAR CRONOGRAMA"
         │
         ▼
   FRONTEND (JavaScript)
   ├─ Valida formulário
   └─ POST /cronograma/gerar
        │
        ▼
   ROTEADOR
   └─ CronogramaController::gerar()
        │
        ▼
   CONTROLLER
   ├─ Valida autenticação
   ├─ Valida dados
   └─ Chama SchedulerService::generate()
        │
        ▼
   SCHEDULER SERVICE
   ├─ Calcular dias disponíveis
   │  └─ dataFim - dataInicio
   │
   ├─ Calcular horas totais
   │  └─ dias * horasDia
   │
   ├─ Buscar tópicos relevantes
   │  └─ Baseado no vestibular
   │
   ├─ Priorizar tópicos
   │  └─ PriorizationService
   │     ├─ peso_vestibular
   │     ├─ dificuldade
   │     ├─ erros_anteriores
   │     └─ dias_sem_revisao
   │
   ├─ Alocar horas
   │  └─ Distribuir proporcionalmente
   │
   ├─ Gerar itens (agenda diária)
   │  └─ Para cada dia até a prova
   │
   └─ Agendar revisões
      ├─ 7 dias
      ├─ 30 dias
      └─ 90 dias
        │
        ▼
   DATABASE
   ├─ INSERT CRONOGRAMA
   ├─ INSERT CRONOGRAMA_ITEMS (múltiplos)
   └─ INSERT REVISOES (múltiplas)
        │
        ▼
   CONTROLLER
   └─ Retorna resposta JSON
        │
        ▼
   FRONTEND
   ├─ Atualiza UI
   ├─ Mostra cronograma
   └─ Exibe mensagem de sucesso ✓
```

---

## 7. PIPELINE DE VALIDAÇÃO

```
INPUT
  │
  ├─ 1️⃣ VALIDAÇÃO SINTÁTICA
  │   ├─ Email é válido?
  │   ├─ Número está em range?
  │   └─ Data é válida?
  │
  ├─ 2️⃣ VALIDAÇÃO SEMÂNTICA
  │   ├─ Usuário existe?
  │   ├─ Vestibular existe?
  │   └─ Acesso é permitido?
  │
  ├─ 3️⃣ REGRAS DE NEGÓCIO
  │   ├─ Cronograma já existe?
  │   ├─ Data de prova é futura?
  │   └─ Horas disponíveis > 0?
  │
  ├─ 4️⃣ CONSTRAINTS DE BD
  │   ├─ Unicidade
  │   ├─ Foreign keys
  │   └─ Check constraints
  │
  └─ ✓ Validação passou!
      │
      ▼
   PROCESSAR
```

---

## 8. ESTADO DO CRONOGRAMA

```
                    CRIADO
                      │
                      ▼
┌─────────────────────────────────────┐
│     ATIVO (estudando)               │
├─────────────────────────────────────┤
│ • Exibindo itens do dia             │
│ • Marcando conclusões               │
│ • Recalculando taxa                 │
└────────────┬───────────────┬────────┘
             │               │
         ✓ Concluído    ⏸ Pausado
             │               │
             ▼               ▼
        ┌────────────┐  ┌──────────┐
        │ CONCLUÍDO  │  │ PAUSADO  │
        ├────────────┤  ├──────────┤
        │ Prova foi! │  │ Esperando│
        │ Análise OK │  │ reabrir  │
        └────────────┘  └──────────┘
```

---

## 9. SISTEMA DE REVISÃO ESPAÇADA

```
ESTUDA TÓPICO
      │
      ▼
MARCAR COMO CONCLUÍDO
      │
      ├─ Agendar revisão em 7 dias
      ├─ Agendar revisão em 30 dias
      └─ Agendar revisão em 90 dias
         │
         ▼
   DIA 7
   ├─ Se não reviu: PENDENTE
   ├─ Se reviu: CONCLUÍDO → Reestud em 30 dias
   └─ Se pulou: VENCIDO → Aumentar frequência
      │
      ▼
   DIA 30
   ├─ Se não reviu: PENDENTE
   ├─ Se reviu: CONCLUÍDO → Reestud em 90 dias
   └─ Se pulou: VENCIDO → Estudar agora
      │
      ▼
   DIA 90
   ├─ Se não reviu: PENDENTE
   ├─ Se reviu: MASTERED ✓
   └─ Se pulou: VENCIDO → Revisar tudo
```

---

## 10. MÉTRICAS DO DASHBOARD

```
┌─────────────────────────────────────────────┐
│        DASHBOARD DO ALUNO                   │
├─────────────────────────────────────────────┤
│                                             │
│  ├─ Dias restantes: 120 dias               │
│  ├─ Horas planejadas: 200h                 │
│  ├─ Horas estudadas: 85h (42.5%)           │
│  └─ Taxa de cumprimento: 42.5% ████░░░░░░  │
│                                             │
│  PRÓXIMAS ATIVIDADES:                       │
│  ├─ [Hoje] Cronograma: Mat + Fís           │
│  ├─ [Amanhã] Revisão: História             │
│  ├─ [Em 2 dias] Simulado FUVEST            │
│  └─ [Em 3 dias] Redação #5                 │
│                                             │
│  GRÁFICOS:                                  │
│  ├─ Evolução semanal (linha)               │
│  ├─ Acertos por matéria (pizza)            │
│  ├─ Tempo por matéria (barra)              │
│  ├─ Histórico de redações (área)           │
│  └─ Desempenho simulados (linha)           │
│                                             │
│  ALERTAS:                                   │
│  ├─ ⚠️ Física: 3 erros críticos             │
│  ├─ ✓ Português: Em dia                    │
│  └─ ⚠️ Redação: 5 dias sem enviar           │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 11. FLUXO DE AUTENTICAÇÃO

```
ACESSO A /dashboard
        │
        ▼
SESSÃO EXISTE?
    ┌───┴────┐
   NÃO       SIM
    │         │
    ▼         ▼
REDIRECIONA  AuthMiddleware
PARA LOGIN   └─ Verifica sessão ativa
    │            └─ Verifica timeout
    │                │
LOGIN              SIM
  │                 │
  ├─ POST           ▼
  │ /login      Carrega usuário
  │                │
  ├─ Valida        ▼
  │ CSRF token  Executa Controller
  │                │
  ├─ Valida        ▼
  │ Email e    Renderiza View
  │ Senha      ou JSON
  │                │
  ├─ Hash match?   ▼
  │   │          Resposta ao Cliente
  │   ├─ NÃO → Erro 401
  │   │
  │   └─ SIM
  │       └─ Criar sessão
  │       └─ Definir cookies
  │       └─ Redirecionar /dashboard
  │
  └─ ✓ Autenticado!
```

---

## 12. ARQUITETURA DO BANCO DE DADOS (Simplificada)

```
USUÁRIOS (Base)
    ├─ VESTIBULARES (O que quer estudar)
    │   ├─ CRONOGRAMAS (Planos)
    │   │   └─ CRONOGRAMA_ITEMS (Dias específicos)
    │   │       └─ TOPICOS (O que estudar)
    │   │           ├─ MATERIAS (Matérias)
    │   │           └─ REVISOES (Agendadas)
    │   │
    │   └─ VESTIB_PESOS (Importância de cada matéria)
    │
    ├─ REDACOES (Textos enviados)
    ├─ SIMULADOS (Testes realizados)
    │   └─ SIMULADO_MATERIAS (Desempenho por matéria)
    ├─ BANCO_ERROS (Erros rastreados)
    ├─ DESEMPENHO (Sumário de progresso)
    └─ EVOLUCAO_SEMANAL (Dados históricos)
```

---

## 13. CICLO DE DESENVOLVIMENTO

```
┌─────────────────────────────────────────────────────┐
│            CICLO DE DESENVOLVIMENTO                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  PLANEJAR  ──────────────────────────────────┐    │
│    │                                         │    │
│    └─► ENTENDER OS REQUISITOS                │    │
│        ├─ Ler documentação                   │    │
│        └─ Entender o fluxo                   │    │
│                                              │    │
│  IMPLEMENTAR ◄─────────────────────────┐    │    │
│    │                                  │    │    │
│    ├─ Criar estrutura de pastas       │    │    │
│    ├─ Implementar Models              │    │    │
│    ├─ Implementar Controllers          │    │    │
│    ├─ Implementar Services             │    │    │
│    ├─ Implementar Views                │    │    │
│    └─ Criar rotas                      │    │    │
│        │                               │    │    │
│        ▼                               │    │    │
│  TESTAR                                │    │    │
│    │                                   │    │    │
│    ├─ Testes unitários                 │    │    │
│    ├─ Testes de integração             │    │    │
│    ├─ Testes de funcionalidade         │    │    │
│    └─ Testes de segurança              │    │    │
│        │                               │    │    │
│        ├─ Passou? ──► DEPLOY ──────────┼────┘    │
│        │                               │         │
│        └─ Falhou? ──► Corrigir ────────┴──────────┘
│
```

---

## 14. TECNOLOGIAS VISUAIS

```
┌─────────────────────────────────────────────────┐
│              STACK TECNOLÓGICO                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  FRONTEND                                       │
│  ┌────────────────────────────────────────┐    │
│  │ HTML5  +  CSS3 + Bootstrap 5          │    │
│  │ JavaScript ES6+  +  Chart.js          │    │
│  │ Responsive Design                      │    │
│  └────────────────────────────────────────┘    │
│           │ AJAX / Fetch API │                 │
│  ┌────────▼────────────────────┬────────┐      │
│  │                              │        │      │
│  BACKEND                        API      │      │
│  ┌──────────────────┐           │       │      │
│  │ PHP 8+           │◄──────────┘       │      │
│  │ ├─ Controllers   │                   │      │
│  │ ├─ Models        │                   │      │
│  │ ├─ Services      │  JSON/REST        │      │
│  │ ├─ Middleware    │                   │      │
│  │ └─ Helpers       │                   │      │
│  └──────────┬───────┘                   │      │
│             │ PDO + Prepared Statements │      │
│  ┌──────────▼─────────────────────────┐        │
│  │      MySQL 8.0+ Database          │        │
│  │  15 Tables, 20+ Indexes, 5 Views │        │
│  └───────────────────────────────────┘        │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 15. ROADMAP DE IMPLEMENTAÇÃO

```
ETAPA 1: ✅ CONCLUÍDA
┌─────────────────────────────────────────────┐
│ Arquitetura, Estrutura e Banco de Dados    │
└─────────────────────────────────────────────┘

ETAPA 2: 🔄 PRÓXIMA
┌─────────────────────────────────────────────┐
│ Backend PHP Completo                        │
│ • Controllers (8)                           │
│ • Models (10)                              │
│ • Services (6)                             │
│ • Middlewares (5)                          │
│ • Testes unitários                         │
└─────────────────────────────────────────────┘

ETAPA 3: ⏳ PROGRAMADA
┌─────────────────────────────────────────────┐
│ Frontend Completo                           │
│ • Layouts com Bootstrap                    │
│ • Páginas de autenticação                  │
│ • CRUD forms                               │
│ • Responsividade                           │
└─────────────────────────────────────────────┘

ETAPA 4: ⏳ PROGRAMADA
┌─────────────────────────────────────────────┐
│ Dashboard e Gráficos                        │
│ • Dashboard com Chart.js                   │
│ • Relatórios em PDF                        │
│ • Exportação de dados                      │
└─────────────────────────────────────────────┘

ETAPA 5: ⏳ PROGRAMADA
┌─────────────────────────────────────────────┐
│ Motor Inteligente                           │
│ • Cronograma adaptativo                    │
│ • Priorização automática                   │
│ • Machine Learning (opcional)              │
└─────────────────────────────────────────────┘

ETAPA 6: ⏳ PROGRAMADA
┌─────────────────────────────────────────────┐
│ Testes e Documentação                       │
│ • Testes de cobertura > 80%                │
│ • Documentação final                       │
│ • Video tutorials                          │
│ • Deploy em produção                       │
└─────────────────────────────────────────────┘
```

---

**Diagramas criados com ❤️ para ajudar na visualização**

*Versão 1.0 - Junho 2026*
