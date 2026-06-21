# DIAGRAMA DE ENTIDADE-RELACIONAMENTO (DER)
## Sistema de Planejamento para Vestibulares

---

## 1. ENTIDADES E RELACIONAMENTOS (Visual ASCII)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DIAGRAMA ER - ESTRUTURA                          │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   USUARIOS   │
                              ├──────────────┤
                              │ *id          │
                              │  email       │
                              │  senha       │
                              │  nome        │
                              │  serie       │
                              │  horas_dia   │
                              │  data_criacão│
                              └───────┬──────┘
                                      │
                    ┌─────────────────┼──────────────────┐
                    │                 │                  │
                    ▼                 ▼                  ▼
            ┌───────────────┐ ┌──────────────┐ ┌──────────────────┐
            │ VESTIBULARES  │ │  CRONOGRAMA  │ │ DESEMPENHO_ALUNO │
            │ (Inscrições)  │ │              │ │                  │
            ├───────────────┤ ├──────────────┤ ├──────────────────┤
            │ *id           │ │ *id          │ │ *id              │
            │ *user_id(FK)  │ │ *user_id(FK) │ │ *user_id(FK)     │
            │ *vestibular   │ │ data_inicio  │ │ total_horas      │
            │ data_prova    │ │ data_fim     │ │ horas_concluidas │
            │ curso         │ │ status       │ │ taxa_cumprimento │
            │ prioridade    │ │ criado_em    │ │ atualizado_em    │
            └───────┬───────┘ └──────────────┘ └──────────────────┘
                    │
                    │ (1:N)
                    │
            ┌───────┴──────────────────────────┐
            │                                   │
            ▼                                   ▼
    ┌──────────────────┐            ┌──────────────────┐
    │ VESTIB_PESOS     │            │ CRONOGRAMA_ITEMS │
    ├──────────────────┤            ├──────────────────┤
    │ *id              │            │ *id              │
    │ *vestibular_id   │            │ *cronograma_id   │
    │ *materia_id      │            │ *topico_id       │
    │ peso             │            │ data_prevista    │
    │ percentual_prova │            │ horas_alocadas   │
    └──────────────────┘            │ status           │
                                    │ concluido_em     │
                                    └──────┬───────────┘
                                           │
                        ┌──────────────────┼──────────────┐
                        │                  │              │
                        ▼                  ▼              ▼
                ┌──────────────┐   ┌──────────────┐  ┌─────────────┐
                │  MATERIAS    │   │  TOPICOS     │  │ REVISOES    │
                ├──────────────┤   ├──────────────┤  ├─────────────┤
                │ *id          │   │ *id          │  │ *id         │
                │ nome         │   │ *materia_id  │  │ *topico_id  │
                │ descricao    │   │ *cronograma_ │  │ *user_id    │
                │ dificuldade  │   │   item_id    │  │ data_estudo │
                └──────┬───────┘   │ subtopico    │  │ proxima_7d  │
                       │           │ dificuldade  │  │ proxima_30d │
                       │           │ peso         │  │ proxima_90d │
                       │           │ ordem        │  │ status      │
                       │           └──────────────┘  └─────────────┘
                       │
                       │ (1:N)
                       │
            ┌──────────┴───────────┬──────────────┐
            │                      │              │
            ▼                      ▼              ▼
    ┌──────────────┐      ┌──────────────┐  ┌──────────────────┐
    │ REDACOES     │      │ SIMULADOS    │  │ BANCO_ERROS      │
    ├──────────────┤      ├──────────────┤  ├──────────────────┤
    │ *id          │      │ *id          │  │ *id              │
    │ *user_id(FK) │      │ *user_id(FK) │  │ *user_id(FK)     │
    │ *materia_id? │      │ nome         │  │ *materia_id(FK)  │
    │ tema         │      │ ano          │  │ *topico_id(FK)   │
    │ texto        │      │ prova_total  │  │ descricao        │
    │ data_envio   │      │ nota_obtida  │  │ tipo_erro        │
    │ data_correcao│      │ percentual   │  │ frequencia       │
    │ competencia_1│      │ tempo_gasto  │  │ prioridade       │
    │ competencia_2│      │ data_prova   │  │ status           │
    │ competencia_3│      │ vestibular   │  │ criado_em        │
    │ competencia_4│      │ observacoes  │  └──────────────────┘
    │ competencia_5│      └──────────────┘
    │ media_geral  │
    │ feedback     │
    └──────────────┘


┌──────────────────────────────────────────────────────────────────────┐
│ LEGENDA:                                                               │
│ * = Chave Primária                                                     │
│ (FK) = Chave Estrangeira                                               │
│ (1:N) = Relacionamento Um-para-Muitos                                  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. MAPEAMENTO DETALHADO DE TABELAS

### **Tabela: USUARIOS**
```
Função: Armazena dados de cadastro e perfil do aluno
PK: id
Indexes: email (UNIQUE), id_sessao

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
email           | VARCHAR(255)  | UNIQUE, NOT NULL
senha           | VARCHAR(255)  | NOT NULL (bcrypt hash)
nome            | VARCHAR(100)  | NOT NULL
serie_escolar   | VARCHAR(50)   | NOT NULL (Ex: "3º ano EM")
horas_disponiveis_dia | INT     | NOT NULL (Ex: 5)
dias_disponiveis| JSON          | Array com dias da semana
materias_dificeis| JSON         | Array de IDs de matérias
data_criacao    | TIMESTAMP     | DEFAULT CURRENT_TIMESTAMP
data_atualizacao| TIMESTAMP     | DEFAULT CURRENT_TIMESTAMP ON UPDATE
status          | ENUM          | 'ativo', 'inativo', 'suspenso'
ultimo_acesso   | TIMESTAMP     | Último login
sessao_token    | VARCHAR(255)  | Token de sessão ativa
```

---

### **Tabela: VESTIBULARES**
```
Função: Vestibulares que o usuário se inscreve
PK: id
FK: user_id → USUARIOS.id
Indexes: user_id, vestibular_nome

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
vestibular_nome | VARCHAR(100)  | NOT NULL (Ex: "FUVEST 2024")
data_prova      | DATE          | NOT NULL
curso_pretendido| VARCHAR(100)  | NOT NULL
prioridade      | INT           | 1-10 (maior = mais importante)
dias_restantes  | INT           | Calculado
status          | ENUM          | 'planejando', 'em_andamento', 'realizado'
data_inscricao  | TIMESTAMP     | DEFAULT CURRENT_TIMESTAMP

FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE
```

---

### **Tabela: VESTIB_PESOS**
```
Função: Peso/importância de cada matéria em cada vestibular
PK: id
FK: vestibular_id, materia_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
vestibular_id   | INT           | NOT NULL (FK)
materia_id      | INT           | NOT NULL (FK)
peso            | DECIMAL(3,1)  | 0.0 - 10.0 (peso para priorização)
percentual_prova| INT           | 0-100 (% da prova)
topicos_criticos| JSON          | Tópicos mais cobrados

FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id)
FOREIGN KEY (materia_id) REFERENCES MATERIAS(id)
PRIMARY KEY (vestibular_id, materia_id)
```

---

### **Tabela: MATERIAS**
```
Função: Catálogo de matérias (Português, Matemática, etc)
PK: id
Indexes: nome (UNIQUE)

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
nome            | VARCHAR(100)  | NOT NULL, UNIQUE
descricao       | TEXT          | Descrição da matéria
dificuldade_base| INT           | 1-5 (nível base de dificuldade)
ordem_padrao    | INT           | Ordem de exibição
ativa           | BOOLEAN       | DEFAULT TRUE
```

---

### **Tabela: TOPICOS**
```
Função: Tópicos de cada matéria (Funções, Logaritmos, etc)
PK: id
FK: materia_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
materia_id      | INT           | NOT NULL (FK)
nome            | VARCHAR(150)  | NOT NULL
descricao       | TEXT          | 
dificuldade     | INT           | 1-5 (complexidade)
peso_global     | INT           | % importância geral
ordem           | INT           | Ordem de estudo
estimado_horas  | INT           | Horas estimadas para aprender
recursos_url    | JSON          | Links para material
palavras_chave  | JSON          | Tags para busca

FOREIGN KEY (materia_id) REFERENCES MATERIAS(id) ON DELETE CASCADE
INDEX (materia_id)
```

---

### **Tabela: CRONOGRAMA**
```
Função: Cronograma geral gerado pelo sistema
PK: id
FK: user_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
vestibular_id   | INT           | NOT NULL (FK)
data_inicio     | DATE          | Data de início do cronograma
data_fim        | DATE          | Data final (dia da prova)
total_horas     | INT           | Total de horas planejadas
horas_alocadas  | INT           | Horas já alocadas
horas_concluidas| INT           | Horas já estudadas
taxa_cumprimento| DECIMAL(3,1)  | Percentual 0-100%
metodo_estudo   | ENUM          | 'pomodoro', 'blocos', 'continuo'
duracao_bloco   | INT           | Minutos (ex: 25 para Pomodoro)
intervalo       | INT           | Minutos de intervalo
status          | ENUM          | 'ativo', 'pausado', 'concluido'
criado_em       | TIMESTAMP     | 
atualizado_em   | TIMESTAMP     | 
proxima_geracao | DATE          | Quando recalcular (semanal)

FOREIGN KEY (user_id) REFERENCES USUARIOS(id)
FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id)
INDEX (user_id, status)
```

---

### **Tabela: CRONOGRAMA_ITEMS**
```
Função: Itens individuais do cronograma (dia a dia)
PK: id
FK: cronograma_id, topico_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
cronograma_id   | INT           | NOT NULL (FK)
topico_id       | INT           | NOT NULL (FK)
data_prevista   | DATE          | Dia planejado
horas_alocadas  | INT           | Horas para este tópico
ordem_dia       | INT           | 1º, 2º, 3º... do dia
metodo          | ENUM          | Técnica específica
status          | ENUM          | 'pendente', 'em_progresso', 'concluido'
concluido_em    | TIMESTAMP     | Quando concluído
horas_gastas    | INT           | Horas realmente gastas
desempenho      | INT           | Score 0-100 (se teste incluído)
observacoes     | TEXT          | Notas do aluno

FOREIGN KEY (cronograma_id) REFERENCES CRONOGRAMA(id) ON DELETE CASCADE
FOREIGN KEY (topico_id) REFERENCES TOPICOS(id)
INDEX (cronograma_id, data_prevista)
```

---

### **Tabela: REVISOES**
```
Função: Sistema de revisão espaçada
PK: id
FK: user_id, topico_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
topico_id       | INT           | NOT NULL (FK)
data_estudo     | DATE          | Quando estudou
data_proxima_7d | DATE          | Próxima revisão (7 dias)
data_proxima_30d| DATE          | Próxima revisão (30 dias)
data_proxima_90d| DATE          | Próxima revisão (90 dias)
revisao_7d_feita| BOOLEAN       | Completada?
revisao_30d_feita| BOOLEAN      | Completada?
revisao_90d_feita| BOOLEAN      | Completada?
prioridade      | INT           | Score de prioridade
ultima_revisao  | TIMESTAMP     | Última vez revisto
frequencia_acertos| INT         | % de acertos em testes
status          | ENUM          | 'pendente', 'concluido', 'vencido'

FOREIGN KEY (user_id) REFERENCES USUARIOS(id)
FOREIGN KEY (topico_id) REFERENCES TOPICOS(id)
INDEX (user_id, status, data_proxima_7d)
```

---

### **Tabela: REDACOES**
```
Função: Registro de redações e correções
PK: id
FK: user_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
numero_sequencia| INT           | Redação #1, #2, #3...
tema            | VARCHAR(255)  | Tema proposto
texto           | LONGTEXT      | Texto enviado
tipo_vestibular | VARCHAR(100)  | Para qual vestibular
data_envio      | TIMESTAMP     | 
data_correcao   | TIMESTAMP     | Quando foi corrigido

competencia_1   | INT           | 0-200 (Demonstração de domínio)
competencia_2   | INT           | 0-200 (Compreensão da proposta)
competencia_3   | INT           | 0-200 (Seleção/organização de dados)
competencia_4   | INT           | 0-200 (Estrutura formal)
competencia_5   | INT           | 0-200 (Proposta de solução)

media_geral     | DECIMAL(4,1)  | Média (0-1000)
feedback        | LONGTEXT      | Observações do corretor
pontos_fortes   | JSON          | Pontos positivos
pontos_fracos   | JSON          | Pontos para melhorar
status          | ENUM          | 'aguardando_correcao', 'corrigida', 'revisada'

FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE
INDEX (user_id, data_envio)
```

---

### **Tabela: SIMULADOS**
```
Função: Registro de simulados realizados
PK: id
FK: user_id, vestibular_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
vestibular_id   | INT           | NOT NULL (FK)
nome            | VARCHAR(150)  | "Simulado FUVEST 2023"
ano_original    | YEAR          | Ano da prova original
data_realizacao | DATE          | Quando o aluno fez
duracao_minutos | INT           | Tempo gasto
nota_total      | DECIMAL(5,1)  | Nota final
percentual_acertos| INT         | % acertos
tempo_medio_questao| INT        | Segundos por questão
observacoes     | TEXT          | Impressões do aluno
status          | ENUM          | 'concluido', 'em_progresso', 'abandonado'

FOREIGN KEY (user_id) REFERENCES USUARIOS(id)
FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id)
INDEX (user_id, data_realizacao)
```

---

### **Tabela: SIMULADO_MATERIAS**
```
Função: Desempenho por matéria em cada simulado
PK: id
FK: simulado_id, materia_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
simulado_id     | INT           | NOT NULL (FK)
materia_id      | INT           | NOT NULL (FK)
total_questoes  | INT           | Total nesta matéria
acertos         | INT           | Quantas acertou
erros           | INT           | Quantas errou
tempo_dispendido| INT           | Minutos gastos
percentual      | INT           | % de acertos
desempenho      | ENUM          | 'excelente', 'bom', 'regular', 'fraco'

FOREIGN KEY (simulado_id) REFERENCES SIMULADOS(id) ON DELETE CASCADE
FOREIGN KEY (materia_id) REFERENCES MATERIAS(id)
PRIMARY KEY (simulado_id, materia_id)
```

---

### **Tabela: BANCO_ERROS**
```
Função: Rastreamento de erros frequentes
PK: id
FK: user_id, topico_id, materia_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
materia_id      | INT           | NOT NULL (FK)
topico_id       | INT           | NOT NULL (FK)
descricao       | TEXT          | O que errou
tipo_erro       | ENUM          | 'conceitual', 'calculo', 'interpretacao'
frequencia      | INT           | Quantas vezes errou
prioridade_calc | DECIMAL(5,2)  | Score automático (0-100)
ultima_ocorrencia| TIMESTAMP    | Último erro
recomendacoes   | JSON          | Sugestões de revisão
status          | ENUM          | 'ativo', 'resolvido', 'ignorado'
criado_em       | TIMESTAMP     | 

FOREIGN KEY (user_id) REFERENCES USUARIOS(id)
FOREIGN KEY (materia_id) REFERENCES MATERIAS(id)
FOREIGN KEY (topico_id) REFERENCES TOPICOS(id)
INDEX (user_id, prioridade_calc)
INDEX (user_id, status)
```

---

### **Tabela: DESEMPENHO_ALUNO**
```
Função: Sumário de desempenho geral
PK: id
FK: user_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
total_horas_estudadas| INT      | Horas totais
horas_planejadas| INT           | Horas planejadas
taxa_cumprimento| DECIMAL(3,1)  | Percentual
redacoes_escritas| INT          | Total
media_redacao   | DECIMAL(4,1)  | Média das competências
simulados_feitos| INT           | Total
media_simulados | DECIMAL(5,1)  | Média dos simulados
erros_criticos  | INT           | Quantidade de erros
topicos_estudados| INT          | Quantos completou
topicos_revisados| INT          | Quantos revisou
ultima_atualizacao| TIMESTAMP   | 

FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE
UNIQUE KEY (user_id)
```

---

### **Tabela: EVOLUCAO_SEMANAL** (Analytics)
```
PK: id
FK: user_id

id              | INT           | AUTO_INCREMENT, PRIMARY KEY
user_id         | INT           | NOT NULL (FK)
semana          | DATE          | Segunda-feira da semana
horas_estudadas | INT           | Total na semana
redacoes        | INT           | Redações na semana
simulados       | INT           | Simulados na semana
taxa_cumprimento| INT           | % da meta
acertos_teste   | INT           | % acertos médios
criado_em       | TIMESTAMP     | 

FOREIGN KEY (user_id) REFERENCES USUARIOS(id)
INDEX (user_id, semana)
```

---

## 3. CHAVES E ÍNDICES CRÍTICOS

### Primary Keys
```sql
- USUARIOS.id
- VESTIBULARES.id
- MATERIAS.id
- TOPICOS.id
- CRONOGRAMA.id
- REDACOES.id
- SIMULADOS.id
- REVISOES.id
- BANCO_ERROS.id
```

### Foreign Keys
```sql
- VESTIBULARES.user_id → USUARIOS.id
- TOPICOS.materia_id → MATERIAS.id
- CRONOGRAMA.user_id → USUARIOS.id
- CRONOGRAMA_ITEMS.cronograma_id → CRONOGRAMA.id
- CRONOGRAMA_ITEMS.topico_id → TOPICOS.id
- REVISOES.user_id → USUARIOS.id
- REVISOES.topico_id → TOPICOS.id
- REDACOES.user_id → USUARIOS.id
- SIMULADOS.user_id → USUARIOS.id
- BANCO_ERROS.user_id → USUARIOS.id
```

### Índices de Performance
```sql
CREATE INDEX idx_usuarios_email ON USUARIOS(email);
CREATE INDEX idx_cronograma_user ON CRONOGRAMA(user_id, status);
CREATE INDEX idx_cronograma_items_data ON CRONOGRAMA_ITEMS(data_prevista);
CREATE INDEX idx_revisoes_pendentes ON REVISOES(user_id, status);
CREATE INDEX idx_erros_prioridade ON BANCO_ERROS(user_id, prioridade_calc);
CREATE INDEX idx_simulados_data ON SIMULADOS(user_id, data_realizacao);
```

---

## 4. RELACIONAMENTOS RESUMIDOS

| Tabela 1 | Tabela 2 | Tipo | Descrição |
|----------|----------|------|-----------|
| USUARIOS | VESTIBULARES | 1:N | Um aluno estuda para vários vestibulares |
| VESTIBULARES | VESTIB_PESOS | 1:N | Um vestibular tem pesos para várias matérias |
| MATERIAS | TOPICOS | 1:N | Uma matéria tem múltiplos tópicos |
| USUARIOS | CRONOGRAMA | 1:N | Um aluno tem múltiplos cronogramas |
| CRONOGRAMA | CRONOGRAMA_ITEMS | 1:N | Um cronograma tem múltiplos itens |
| TOPICOS | REVISOES | 1:N | Um tópico tem múltiplas revisões |
| USUARIOS | REDACOES | 1:N | Um aluno escreve múltiplas redações |
| USUARIOS | SIMULADOS | 1:N | Um aluno faz múltiplos simulados |
| USUARIOS | BANCO_ERROS | 1:N | Um aluno comete múltiplos erros rastreados |

---

**Versão DER:** 1.0  
**Banco de Dados:** MySQL 8.0+  
**Total de Tabelas:** 15 principais + 3 auxiliares
