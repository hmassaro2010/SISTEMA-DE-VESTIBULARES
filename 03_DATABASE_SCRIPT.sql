-- =====================================================
-- SISTEMA DE PLANEJAMENTO PARA VESTIBULARES
-- Script de criação completo do banco de dados
-- MySQL 8.0+
-- =====================================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS vestibulares_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE vestibulares_db;

-- =====================================================
-- TABELA: USUARIOS
-- =====================================================
CREATE TABLE USUARIOS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    serie_escolar VARCHAR(50) NOT NULL,
    horas_disponiveis_dia INT NOT NULL DEFAULT 5,
    dias_disponiveis JSON,
    materias_dificeis JSON,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('ativo', 'inativo', 'suspenso') DEFAULT 'ativo',
    ultimo_acesso TIMESTAMP NULL,
    sessao_token VARCHAR(255),
    
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_data_criacao (data_criacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: VESTIBULARES
-- =====================================================
CREATE TABLE VESTIBULARES (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vestibular_nome VARCHAR(100) NOT NULL,
    data_prova DATE NOT NULL,
    curso_pretendido VARCHAR(100) NOT NULL,
    prioridade INT DEFAULT 5,
    dias_restantes INT GENERATED ALWAYS AS (DATEDIFF(data_prova, CURDATE())) STORED,
    status ENUM('planejando', 'em_andamento', 'realizado') DEFAULT 'planejando',
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_data_prova (data_prova)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: MATERIAS
-- =====================================================
CREATE TABLE MATERIAS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    dificuldade_base INT DEFAULT 3,
    ordem_padrao INT,
    ativa BOOLEAN DEFAULT TRUE,
    
    INDEX idx_nome (nome),
    INDEX idx_ativa (ativa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: TOPICOS
-- =====================================================
CREATE TABLE TOPICOS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    materia_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    dificuldade INT DEFAULT 3,
    peso_global INT DEFAULT 5,
    ordem INT,
    estimado_horas INT DEFAULT 10,
    recursos_url JSON,
    palavras_chave JSON,
    
    FOREIGN KEY (materia_id) REFERENCES MATERIAS(id) ON DELETE CASCADE,
    INDEX idx_materia_id (materia_id),
    INDEX idx_peso_global (peso_global),
    UNIQUE KEY uk_materia_nome (materia_id, nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: VESTIB_PESOS
-- =====================================================
CREATE TABLE VESTIB_PESOS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vestibular_id INT NOT NULL,
    materia_id INT NOT NULL,
    peso DECIMAL(3,1) DEFAULT 5.0,
    percentual_prova INT DEFAULT 10,
    topicos_criticos JSON,
    
    FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES MATERIAS(id) ON DELETE CASCADE,
    UNIQUE KEY uk_vestib_materia (vestibular_id, materia_id),
    INDEX idx_peso (peso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: CRONOGRAMA
-- =====================================================
CREATE TABLE CRONOGRAMA (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vestibular_id INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    total_horas INT NOT NULL,
    horas_alocadas INT DEFAULT 0,
    horas_concluidas INT DEFAULT 0,
    taxa_cumprimento DECIMAL(3,1) DEFAULT 0.0,
    metodo_estudo ENUM('pomodoro', 'blocos', 'continuo') DEFAULT 'pomodoro',
    duracao_bloco INT DEFAULT 25,
    intervalo INT DEFAULT 5,
    status ENUM('ativo', 'pausado', 'concluido') DEFAULT 'ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    proxima_geracao DATE,
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_data_inicio (data_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: CRONOGRAMA_ITEMS
-- =====================================================
CREATE TABLE CRONOGRAMA_ITEMS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cronograma_id INT NOT NULL,
    topico_id INT NOT NULL,
    data_prevista DATE NOT NULL,
    horas_alocadas INT DEFAULT 1,
    ordem_dia INT,
    metodo VARCHAR(50),
    status ENUM('pendente', 'em_progresso', 'concluido') DEFAULT 'pendente',
    concluido_em TIMESTAMP NULL,
    horas_gastas INT DEFAULT 0,
    desempenho INT,
    observacoes TEXT,
    
    FOREIGN KEY (cronograma_id) REFERENCES CRONOGRAMA(id) ON DELETE CASCADE,
    FOREIGN KEY (topico_id) REFERENCES TOPICOS(id) ON DELETE CASCADE,
    INDEX idx_cronograma_id (cronograma_id),
    INDEX idx_data_prevista (data_prevista),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: REVISOES
-- =====================================================
CREATE TABLE REVISOES (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    topico_id INT NOT NULL,
    data_estudo DATE NOT NULL,
    data_proxima_7d DATE,
    data_proxima_30d DATE,
    data_proxima_90d DATE,
    revisao_7d_feita BOOLEAN DEFAULT FALSE,
    revisao_30d_feita BOOLEAN DEFAULT FALSE,
    revisao_90d_feita BOOLEAN DEFAULT FALSE,
    prioridade INT DEFAULT 50,
    ultima_revisao TIMESTAMP NULL,
    frequencia_acertos INT,
    status ENUM('pendente', 'concluido', 'vencido') DEFAULT 'pendente',
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    FOREIGN KEY (topico_id) REFERENCES TOPICOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_data_proxima_7d (data_proxima_7d),
    INDEX idx_prioridade (prioridade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: REDACOES
-- =====================================================
CREATE TABLE REDACOES (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    numero_sequencia INT,
    tema VARCHAR(255) NOT NULL,
    texto LONGTEXT,
    tipo_vestibular VARCHAR(100),
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_correcao TIMESTAMP NULL,
    
    competencia_1 INT DEFAULT 0,
    competencia_2 INT DEFAULT 0,
    competencia_3 INT DEFAULT 0,
    competencia_4 INT DEFAULT 0,
    competencia_5 INT DEFAULT 0,
    
    media_geral DECIMAL(4,1) DEFAULT 0.0,
    feedback LONGTEXT,
    pontos_fortes JSON,
    pontos_fracos JSON,
    status ENUM('aguardando_correcao', 'corrigida', 'revisada') DEFAULT 'aguardando_correcao',
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_data_envio (data_envio),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: SIMULADOS
-- =====================================================
CREATE TABLE SIMULADOS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vestibular_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    ano_original YEAR,
    data_realizacao DATE NOT NULL,
    duracao_minutos INT,
    nota_total DECIMAL(5,1),
    percentual_acertos INT,
    tempo_medio_questao INT,
    observacoes TEXT,
    status ENUM('concluido', 'em_progresso', 'abandonado') DEFAULT 'concluido',
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    FOREIGN KEY (vestibular_id) REFERENCES VESTIBULARES(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_data_realizacao (data_realizacao),
    INDEX idx_percentual_acertos (percentual_acertos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: SIMULADO_MATERIAS
-- =====================================================
CREATE TABLE SIMULADO_MATERIAS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    simulado_id INT NOT NULL,
    materia_id INT NOT NULL,
    total_questoes INT,
    acertos INT,
    erros INT,
    tempo_dispendido INT,
    percentual INT,
    desempenho ENUM('excelente', 'bom', 'regular', 'fraco'),
    
    FOREIGN KEY (simulado_id) REFERENCES SIMULADOS(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES MATERIAS(id) ON DELETE CASCADE,
    UNIQUE KEY uk_simulado_materia (simulado_id, materia_id),
    INDEX idx_percentual (percentual)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: BANCO_ERROS
-- =====================================================
CREATE TABLE BANCO_ERROS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    materia_id INT NOT NULL,
    topico_id INT NOT NULL,
    descricao TEXT,
    tipo_erro ENUM('conceitual', 'calculo', 'interpretacao') DEFAULT 'conceitual',
    frequencia INT DEFAULT 1,
    prioridade_calc DECIMAL(5,2) DEFAULT 50.0,
    ultima_ocorrencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recomendacoes JSON,
    status ENUM('ativo', 'resolvido', 'ignorado') DEFAULT 'ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES MATERIAS(id) ON DELETE CASCADE,
    FOREIGN KEY (topico_id) REFERENCES TOPICOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_prioridade_calc (prioridade_calc),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: DESEMPENHO_ALUNO
-- =====================================================
CREATE TABLE DESEMPENHO_ALUNO (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    total_horas_estudadas INT DEFAULT 0,
    horas_planejadas INT DEFAULT 0,
    taxa_cumprimento DECIMAL(3,1) DEFAULT 0.0,
    redacoes_escritas INT DEFAULT 0,
    media_redacao DECIMAL(4,1),
    simulados_feitos INT DEFAULT 0,
    media_simulados DECIMAL(5,1),
    erros_criticos INT DEFAULT 0,
    topicos_estudados INT DEFAULT 0,
    topicos_revisados INT DEFAULT 0,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABELA: EVOLUCAO_SEMANAL (Analytics)
-- =====================================================
CREATE TABLE EVOLUCAO_SEMANAL (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    semana DATE NOT NULL,
    horas_estudadas INT DEFAULT 0,
    redacoes INT DEFAULT 0,
    simulados INT DEFAULT 0,
    taxa_cumprimento INT DEFAULT 0,
    acertos_teste INT DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES USUARIOS(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_semana (semana),
    UNIQUE KEY uk_user_semana (user_id, semana)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERIR DADOS INICIAIS: MATERIAS
-- =====================================================
INSERT INTO MATERIAS (nome, descricao, dificuldade_base, ordem_padrao, ativa) VALUES
('Português', 'Língua portuguesa, interpretação e análise linguística', 3, 1, TRUE),
('Matemática', 'Álgebra, geometria, trigonometria, estatística', 4, 2, TRUE),
('História', 'História do Brasil e Mundial', 2, 3, TRUE),
('Geografia', 'Geografia física, humana e econômica', 2, 4, TRUE),
('Física', 'Mecânica, termodinâmica, óptica, eletromagnetismo', 4, 5, TRUE),
('Química', 'Química geral, orgânica, físico-química', 4, 6, TRUE),
('Biologia', 'Biologia celular, genética, ecologia', 3, 7, TRUE),
('Literatura', 'Análise de obras e movimentos literários', 3, 8, TRUE),
('Filosofia', 'Filosofia, ética e lógica', 2, 9, TRUE),
('Sociologia', 'Sociologia, sociedade e cultura', 2, 10, TRUE);

-- =====================================================
-- INSERIR DADOS INICIAIS: TOPICOS (Exemplos)
-- =====================================================

-- PORTUGUÊS
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='Português'), 'Interpretação de Texto', 'Compreensão de textos diversos', 3, 10, 1, 15),
((SELECT id FROM MATERIAS WHERE nome='Português'), 'Gramática', 'Análise sintática e morfológica', 4, 8, 2, 20),
((SELECT id FROM MATERIAS WHERE nome='Português'), 'Pontuação', 'Uso correto de pontuação', 2, 5, 3, 10),
((SELECT id FROM MATERIAS WHERE nome='Português'), 'Ortografia', 'Regras ortográficas', 2, 4, 4, 8);

-- MATEMÁTICA
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='Matemática'), 'Funções', 'Funções lineares, quadráticas, exponenciais', 4, 10, 1, 20),
((SELECT id FROM MATERIAS WHERE nome='Matemática'), 'Trigonometria', 'Seno, cosseno, tangente, identidades', 5, 9, 2, 25),
((SELECT id FROM MATERIAS WHERE nome='Matemática'), 'Geometria', 'Geometria plana e espacial', 4, 8, 3, 22),
((SELECT id FROM MATERIAS WHERE nome='Matemática'), 'Logaritmos', 'Logaritmos e equações logarítmicas', 4, 7, 4, 15),
((SELECT id FROM MATERIAS WHERE nome='Matemática'), 'Probabilidade', 'Análise combinatória e probabilidade', 4, 8, 5, 18);

-- HISTÓRIA
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='História'), 'Brasil Colonial', 'História do Brasil colônia', 2, 6, 1, 12),
((SELECT id FROM MATERIAS WHERE nome='História'), 'República Velha', 'Período republicano até 1930', 3, 7, 2, 14),
((SELECT id FROM MATERIAS WHERE nome='História'), 'Era Vargas', 'Era Vargas (1930-1945)', 3, 6, 3, 12),
((SELECT id FROM MATERIAS WHERE nome='História'), 'Ditadura Militar', 'Período militar (1964-1985)', 3, 7, 4, 13);

-- FÍSICA
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='Física'), 'Cinemática', 'Movimentos e velocidade', 4, 8, 1, 18),
((SELECT id FROM MATERIAS WHERE nome='Física'), 'Dinâmica', 'Forças e leis de Newton', 4, 9, 2, 20),
((SELECT id FROM MATERIAS WHERE nome='Física'), 'Termodinâmica', 'Calor, temperatura, máquinas térmicas', 4, 8, 3, 19),
((SELECT id FROM MATERIAS WHERE nome='Física'), 'Óptica', 'Luz, reflexão, refração', 4, 6, 4, 15);

-- QUÍMICA
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='Química'), 'Estrutura Atômica', 'Átomo, elementos, isótopos', 4, 8, 1, 16),
((SELECT id FROM MATERIAS WHERE nome='Química'), 'Ligações Químicas', 'Iônica, covalente, metálica', 4, 9, 2, 18),
((SELECT id FROM MATERIAS WHERE nome='Química'), 'Reações Químicas', 'Balanceamento, estequiometria', 5, 10, 3, 22),
((SELECT id FROM MATERIAS WHERE nome='Química'), 'Soluções', 'Concentração, solubilidade', 4, 7, 4, 16);

-- BIOLOGIA
INSERT INTO TOPICOS (materia_id, nome, descricao, dificuldade, peso_global, ordem, estimado_horas) VALUES
((SELECT id FROM MATERIAS WHERE nome='Biologia'), 'Célula', 'Estrutura e função celular', 3, 8, 1, 16),
((SELECT id FROM MATERIAS WHERE nome='Biologia'), 'Genética', 'Hereditariedade, genes, mutações', 3, 9, 2, 18),
((SELECT id FROM MATERIAS WHERE nome='Biologia'), 'Evolução', 'Teorias evolutivas, seleção natural', 3, 7, 3, 15),
((SELECT id FROM MATERIAS WHERE nome='Biologia'), 'Ecologia', 'Ecossistemas, ciclos, biodiversidade', 3, 7, 4, 14);

-- =====================================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- =====================================================

-- Índices compostos para queries comuns
CREATE INDEX idx_cronograma_user_status ON CRONOGRAMA(user_id, status);
CREATE INDEX idx_revisoes_user_status ON REVISOES(user_id, status);
CREATE INDEX idx_erros_user_prioridade ON BANCO_ERROS(user_id, prioridade_calc);
CREATE INDEX idx_simulados_user_data ON SIMULADOS(user_id, data_realizacao);
CREATE INDEX idx_redacoes_user_data ON REDACOES(user_id, data_envio);

-- =====================================================
-- TRIGGERS (Automação de atualizações)
-- =====================================================

-- Atualizar taxa de cumprimento do cronograma ao marcar item como concluído
DELIMITER //
CREATE TRIGGER tr_atualizar_taxa_cumprimento 
AFTER UPDATE ON CRONOGRAMA_ITEMS
FOR EACH ROW
BEGIN
    DECLARE total_horas INT;
    DECLARE horas_concluidas INT;
    DECLARE cron_id INT;
    
    SELECT cronograma_id INTO cron_id FROM CRONOGRAMA_ITEMS WHERE id = NEW.id;
    
    SELECT SUM(horas_alocadas) INTO total_horas 
    FROM CRONOGRAMA_ITEMS WHERE cronograma_id = cron_id;
    
    SELECT SUM(horas_gastas) INTO horas_concluidas 
    FROM CRONOGRAMA_ITEMS WHERE cronograma_id = cron_id AND status = 'concluido';
    
    IF horas_concluidas IS NULL THEN SET horas_concluidas = 0; END IF;
    
    UPDATE CRONOGRAMA 
    SET horas_concluidas = horas_concluidas,
        taxa_cumprimento = (horas_concluidas / total_horas) * 100
    WHERE id = cron_id;
END //
DELIMITER ;

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View: Cronograma do aluno para a semana atual
CREATE VIEW v_cronograma_semana_atual AS
SELECT 
    u.nome,
    v.vestibular_nome,
    t.nome AS topico,
    m.nome AS materia,
    ci.data_prevista,
    ci.horas_alocadas,
    ci.status
FROM CRONOGRAMA_ITEMS ci
JOIN CRONOGRAMA c ON ci.cronograma_id = c.id
JOIN USUARIOS u ON c.user_id = u.id
JOIN VESTIBULARES v ON c.vestibular_id = v.id
JOIN TOPICOS t ON ci.topico_id = t.id
JOIN MATERIAS m ON t.materia_id = m.id
WHERE WEEK(ci.data_prevista) = WEEK(CURDATE())
ORDER BY ci.data_prevista, ci.ordem_dia;

-- View: Revisões pendentes por usuário
CREATE VIEW v_revisoes_pendentes AS
SELECT 
    u.nome,
    m.nome AS materia,
    t.nome AS topico,
    r.status,
    r.data_proxima_7d,
    r.data_proxima_30d,
    r.data_proxima_90d,
    r.prioridade
FROM REVISOES r
JOIN USUARIOS u ON r.user_id = u.id
JOIN TOPICOS t ON r.topico_id = t.id
JOIN MATERIAS m ON t.materia_id = m.id
WHERE r.status = 'pendente'
ORDER BY r.prioridade DESC;

-- View: Erros críticos por aluno
CREATE VIEW v_erros_criticos AS
SELECT 
    u.nome,
    m.nome AS materia,
    t.nome AS topico,
    be.descricao,
    be.frequencia,
    be.prioridade_calc,
    be.tipo_erro
FROM BANCO_ERROS be
JOIN USUARIOS u ON be.user_id = u.id
JOIN MATERIAS m ON be.materia_id = m.id
JOIN TOPICOS t ON be.topico_id = t.id
WHERE be.status = 'ativo' AND be.prioridade_calc >= 70
ORDER BY be.user_id, be.prioridade_calc DESC;

-- View: Evolução de redações
CREATE VIEW v_evolucao_redacoes AS
SELECT 
    u.nome,
    r.numero_sequencia,
    r.tema,
    r.competencia_1,
    r.competencia_2,
    r.competencia_3,
    r.competencia_4,
    r.competencia_5,
    r.media_geral,
    r.data_envio,
    r.data_correcao
FROM REDACOES r
JOIN USUARIOS u ON r.user_id = u.id
ORDER BY r.user_id, r.data_envio;

-- View: Desempenho em simulados
CREATE VIEW v_desempenho_simulados AS
SELECT 
    u.nome,
    v.vestibular_nome,
    s.nome,
    s.ano_original,
    s.data_realizacao,
    s.percentual_acertos,
    s.nota_total,
    sm.materia_id,
    m.nome AS materia,
    sm.percentual AS percentual_materia,
    sm.desempenho
FROM SIMULADOS s
JOIN USUARIOS u ON s.user_id = u.id
JOIN VESTIBULARES v ON s.vestibular_id = v.id
JOIN SIMULADO_MATERIAS sm ON s.id = sm.simulado_id
JOIN MATERIAS m ON sm.materia_id = m.id
ORDER BY u.nome, s.data_realizacao DESC;

-- =====================================================
-- PROCEDURES ÚTEIS
-- =====================================================

-- Procedure: Calcular prioridade automática de um erro
DELIMITER //
CREATE PROCEDURE sp_calcular_prioridade_erro(
    IN p_user_id INT,
    IN p_topico_id INT
)
BEGIN
    DECLARE v_peso_vestibular DECIMAL(3,1);
    DECLARE v_dificuldade INT;
    DECLARE v_frequencia_erros INT;
    DECLARE v_dias_sem_revisao INT;
    DECLARE v_prioridade DECIMAL(5,2);
    
    -- Buscar peso do vestibular
    SELECT COALESCE(MAX(vp.peso), 5.0) INTO v_peso_vestibular
    FROM VESTIB_PESOS vp
    JOIN TOPICOS t ON vp.materia_id = t.materia_id
    WHERE t.id = p_topico_id;
    
    -- Buscar dificuldade do tópico
    SELECT dificuldade INTO v_dificuldade FROM TOPICOS WHERE id = p_topico_id;
    
    -- Buscar frequência de erros
    SELECT COALESCE(frequencia, 0) INTO v_frequencia_erros
    FROM BANCO_ERROS WHERE user_id = p_user_id AND topico_id = p_topico_id;
    
    -- Buscar dias desde última revisão
    SELECT COALESCE(DATEDIFF(CURDATE(), MAX(ultima_revisao)), 999) INTO v_dias_sem_revisao
    FROM REVISOES WHERE user_id = p_user_id AND topico_id = p_topico_id;
    
    -- Calcular prioridade
    SET v_prioridade = (v_peso_vestibular * 10) + (v_dificuldade * 8) + (v_frequencia_erros * 5) + (v_dias_sem_revisao * 0.5);
    
    -- Atualizar
    UPDATE BANCO_ERROS 
    SET prioridade_calc = v_prioridade
    WHERE user_id = p_user_id AND topico_id = p_topico_id;
END //
DELIMITER ;

-- =====================================================
-- DADOS DE TESTE (COMENTADO - DESCOMENTE PARA USAR)
-- =====================================================
/*
-- Inserir usuário de teste
INSERT INTO USUARIOS (email, senha, nome, serie_escolar, horas_disponiveis_dia, status)
VALUES ('aluno@exemplo.com', 
        '$2y$10$examplehashpassword', 
        'João Silva', 
        '3º ano EM', 
        5, 
        'ativo');

-- Inserir vestibular de teste
INSERT INTO VESTIBULARES (user_id, vestibular_nome, data_prova, curso_pretendido, prioridade, status)
VALUES (1, 'FUVEST 2024', '2024-11-10', 'Engenharia Civil', 10, 'planejando');

-- Inserir cronograma de teste
INSERT INTO CRONOGRAMA (user_id, vestibular_id, data_inicio, data_fim, total_horas, metodo_estudo, status)
VALUES (1, 1, CURDATE(), '2024-11-10', 200, 'pomodoro', 'ativo');
*/

-- =====================================================
-- FIM DO SCRIPT DE CRIAÇÃO
-- =====================================================
-- Total de tabelas: 15
-- Views: 5
-- Procedures: 1
-- Triggers: 1
-- Data criação: Junho 2026
-- Versão: 1.0
