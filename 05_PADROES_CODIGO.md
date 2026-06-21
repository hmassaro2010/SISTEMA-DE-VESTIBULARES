# PADRÕES DE CÓDIGO E CONVENÇÕES
## Sistema de Planejamento para Vestibulares

---

## 1. PADRÃO MVC - ESTRUTURA BÁSICA

### 1.1 BaseController (Classe Base)

```php
<?php
// app/controllers/BaseController.php

namespace App\Controllers;

use App\Exceptions\AuthException;

abstract class BaseController
{
    protected $view;
    protected $request;
    protected $response;
    protected $user = null;
    
    public function __construct()
    {
        $this->checkAuthentication();
        $this->loadRequest();
    }
    
    /**
     * Verifica se usuário está autenticado
     * @throws AuthException
     */
    protected function checkAuthentication()
    {
        if (!isset($_SESSION['user_id'])) {
            throw new AuthException('Usuário não autenticado');
        }
        
        // Carregar dados do usuário
        $userModel = new \App\Models\User();
        $this->user = $userModel->findById($_SESSION['user_id']);
    }
    
    /**
     * Renderiza uma view com dados
     */
    protected function render($view, $data = [])
    {
        extract($data);
        
        ob_start();
        require "app/views/{$view}.php";
        $content = ob_get_clean();
        
        // Renderizar layout base
        require "app/views/layouts/base.php";
    }
    
    /**
     * Retorna JSON (para API)
     */
    protected function json($status, $message, $data = null, $code = 200)
    {
        header('Content-Type: application/json');
        http_response_code($code);
        
        echo json_encode([
            'status' => $status,
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        
        exit;
    }
    
    /**
     * Retorna sucesso
     */
    protected function success($message, $data = null, $code = 200)
    {
        $this->json('success', $message, $data, $code);
    }
    
    /**
     * Retorna erro
     */
    protected function error($message, $data = null, $code = 400)
    {
        $this->json('error', $message, $data, $code);
    }
    
    /**
     * Faz validação de dados
     */
    protected function validate($data, $rules)
    {
        $validator = new \App\Services\ValidationService();
        return $validator->validate($data, $rules);
    }
    
    /**
     * Carrega dados da requisição (GET/POST)
     */
    protected function loadRequest()
    {
        $this->request = [
            'method' => $_SERVER['REQUEST_METHOD'],
            'get'    => $_GET,
            'post'   => $_POST,
            'files'  => $_FILES
        ];
    }
    
    /**
     * Obtém valor de GET/POST
     */
    protected function input($key, $default = null)
    {
        return $_REQUEST[$key] ?? $default;
    }
}
```

---

### 1.2 Exemplo: CronogramaController

```php
<?php
// app/controllers/CronogramaController.php

namespace App\Controllers;

use App\Models\Cronograma;
use App\Models\Vestibular;
use App\Services\SchedulerService;

class CronogramaController extends BaseController
{
    private $cronogramaModel;
    private $schedulerService;
    
    public function __construct()
    {
        parent::__construct();
        
        $this->cronogramaModel = new Cronograma();
        $this->schedulerService = new SchedulerService();
    }
    
    /**
     * GET /cronograma
     * Lista cronogramas do usuário
     */
    public function index()
    {
        $cronogramas = $this->cronogramaModel->findByUserId($this->user->id);
        
        return $this->render('cronograma/index', [
            'cronogramas' => $cronogramas,
            'user' => $this->user
        ]);
    }
    
    /**
     * GET /cronograma/:id
     * Exibe detalhes do cronograma
     */
    public function show($id)
    {
        $cronograma = $this->cronogramaModel->findById($id);
        
        // Validar propriedade
        if ($cronograma->user_id !== $this->user->id) {
            throw new \App\Exceptions\AuthException('Acesso negado');
        }
        
        $items = $cronograma->getItems();
        
        return $this->render('cronograma/detalhes', [
            'cronograma' => $cronograma,
            'items' => $items
        ]);
    }
    
    /**
     * POST /cronograma
     * Cria novo cronograma
     */
    public function store()
    {
        // Validar dados
        $rules = [
            'vestibular_id' => 'required|integer',
            'metodo_estudo' => 'required|in:pomodoro,blocos,continuo',
            'duracao_bloco' => 'required|integer|min:5|max:120'
        ];
        
        $errors = $this->validate($_POST, $rules);
        if (!empty($errors)) {
            return $this->error('Validação falhou', $errors, 400);
        }
        
        // Criar cronograma
        $vestibular = new Vestibular();
        $vest = $vestibular->findById($_POST['vestibular_id']);
        
        if (!$vest) {
            return $this->error('Vestibular não encontrado', null, 404);
        }
        
        $data = [
            'user_id' => $this->user->id,
            'vestibular_id' => $vest->id,
            'data_inicio' => date('Y-m-d'),
            'data_fim' => $vest->data_prova,
            'metodo_estudo' => $_POST['metodo_estudo'],
            'duracao_bloco' => $_POST['duracao_bloco'],
            'status' => 'ativo'
        ];
        
        $cronograma = $this->cronogramaModel->create($data);
        
        // Gerar cronograma inteligente
        $this->schedulerService->generate($cronograma);
        
        return $this->success(
            'Cronograma criado com sucesso',
            ['cronograma_id' => $cronograma->id],
            201
        );
    }
    
    /**
     * POST /cronograma/gerar
     * Gera cronograma automático
     */
    public function gerar()
    {
        $cronograma_id = $this->input('cronograma_id');
        $cronograma = $this->cronogramaModel->findById($cronograma_id);
        
        if ($cronograma->user_id !== $this->user->id) {
            return $this->error('Acesso negado', null, 403);
        }
        
        // Limpar cronograma anterior
        $cronograma->clearItems();
        
        // Gerar novo
        $scheduler = new SchedulerService();
        $scheduler->generate($cronograma);
        
        return $this->success('Cronograma regenerado com sucesso');
    }
    
    /**
     * PUT /cronograma/:id
     * Atualiza cronograma
     */
    public function update($id)
    {
        $cronograma = $this->cronogramaModel->findById($id);
        
        if ($cronograma->user_id !== $this->user->id) {
            return $this->error('Acesso negado', null, 403);
        }
        
        $updates = [
            'metodo_estudo' => $this->input('metodo_estudo', $cronograma->metodo_estudo),
            'duracao_bloco' => $this->input('duracao_bloco', $cronograma->duracao_bloco),
            'status' => $this->input('status', $cronograma->status)
        ];
        
        $cronograma->update($updates);
        
        return $this->success('Cronograma atualizado com sucesso');
    }
}
```

---

### 1.3 BaseModel (Classe Base para Models)

```php
<?php
// app/models/BaseModel.php

namespace App\Models;

use PDO;
use PDOException;

abstract class BaseModel
{
    protected static $table;
    protected static $primaryKey = 'id';
    protected static $db;
    
    protected $attributes = [];
    protected $original = [];
    protected $changes = [];
    
    /**
     * Inicializa conexão com BD
     */
    public static function init($pdo)
    {
        self::$db = $pdo;
    }
    
    /**
     * Buscar por ID
     */
    public static function findById($id)
    {
        $query = "SELECT * FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id";
        
        $stmt = self::$db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        $result = $stmt->fetch(PDO::FETCH_OBJ);
        
        return $result ? new static($result) : null;
    }
    
    /**
     * Buscar todos
     */
    public static function all()
    {
        $query = "SELECT * FROM " . static::$table;
        
        $stmt = self::$db->query($query);
        $results = $stmt->fetchAll(PDO::FETCH_OBJ);
        
        return array_map(fn($row) => new static($row), $results);
    }
    
    /**
     * Buscar onde condição
     */
    public static function where($column, $operator, $value = null)
    {
        if ($value === null) {
            $value = $operator;
            $operator = '=';
        }
        
        $query = "SELECT * FROM " . static::$table . " WHERE {$column} {$operator} :value";
        
        $stmt = self::$db->prepare($query);
        $stmt->bindParam(':value', $value);
        $stmt->execute();
        
        $results = $stmt->fetchAll(PDO::FETCH_OBJ);
        
        return array_map(fn($row) => new static($row), $results);
    }
    
    /**
     * Criar novo registro
     */
    public static function create($data)
    {
        $columns = implode(', ', array_keys($data));
        $placeholders = implode(', ', array_map(fn($k) => ":{$k}", array_keys($data)));
        
        $query = "INSERT INTO " . static::$table . " ({$columns}) VALUES ({$placeholders})";
        
        $stmt = self::$db->prepare($query);
        
        foreach ($data as $key => $value) {
            $stmt->bindValue(":{$key}", $value);
        }
        
        if ($stmt->execute()) {
            $id = self::$db->lastInsertId();
            return static::findById($id);
        }
        
        throw new \Exception('Erro ao criar registro');
    }
    
    /**
     * Construtor
     */
    public function __construct($data = [])
    {
        foreach ($data as $key => $value) {
            $this->$key = $value;
            $this->attributes[$key] = $value;
            $this->original[$key] = $value;
        }
    }
    
    /**
     * Obter atributo
     */
    public function __get($name)
    {
        return $this->attributes[$name] ?? null;
    }
    
    /**
     * Definir atributo
     */
    public function __set($name, $value)
    {
        $this->attributes[$name] = $value;
        
        if (($this->original[$name] ?? null) !== $value) {
            $this->changes[$name] = $value;
        }
    }
    
    /**
     * Salvar mudanças
     */
    public function save()
    {
        if (empty($this->changes)) {
            return true;
        }
        
        $set = implode(', ', array_map(fn($k) => "{$k} = :{$k}", array_keys($this->changes)));
        
        $query = "UPDATE " . static::$table . " SET {$set} WHERE " . static::$primaryKey . " = :id";
        
        $stmt = self::$db->prepare($query);
        $stmt->bindValue(':id', $this->attributes[static::$primaryKey]);
        
        foreach ($this->changes as $key => $value) {
            $stmt->bindValue(":{$key}", $value);
        }
        
        return $stmt->execute();
    }
    
    /**
     * Atualizar
     */
    public function update($data)
    {
        foreach ($data as $key => $value) {
            $this->$key = $value;
        }
        
        return $this->save();
    }
    
    /**
     * Deletar
     */
    public function delete()
    {
        $query = "DELETE FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id";
        
        $stmt = self::$db->prepare($query);
        $stmt->bindValue(':id', $this->attributes[static::$primaryKey]);
        
        return $stmt->execute();
    }
}
```

---

### 1.4 Exemplo: User Model

```php
<?php
// app/models/User.php

namespace App\Models;

use PDO;

class User extends BaseModel
{
    protected static $table = 'USUARIOS';
    
    /**
     * Buscar por email
     */
    public static function findByEmail($email)
    {
        $query = "SELECT * FROM " . static::$table . " WHERE email = :email";
        
        $stmt = self::$db->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        $result = $stmt->fetch(PDO::FETCH_OBJ);
        
        return $result ? new static($result) : null;
    }
    
    /**
     * Verificar senha
     */
    public function verifyPassword($password)
    {
        return password_verify($password, $this->senha);
    }
    
    /**
     * Hash de senha
     */
    public static function hashPassword($password)
    {
        return password_hash($password, PASSWORD_BCRYPT);
    }
    
    /**
     * Obter cronogramas do usuário
     */
    public function getCronogramas()
    {
        $cronogramaModel = new Cronograma();
        return $cronogramaModel->findByUserId($this->id);
    }
    
    /**
     * Obter desempenho
     */
    public function getDesempenho()
    {
        $desempenhoModel = new Desempenho();
        return $desempenhoModel->findByUserId($this->id);
    }
}
```

---

## 2. PADRÃO SERVICE - LÓGICA DE NEGÓCIO

### 2.1 Exemplo: SchedulerService

```php
<?php
// app/services/SchedulerService.php

namespace App\Services;

use App\Models\Cronograma;
use App\Models\CronogramaItem;
use App\Models\Topico;
use App\Models\Vestibular;
use App\Models\VestibPeso;

class SchedulerService
{
    private $priorizationService;
    
    public function __construct()
    {
        $this->priorizationService = new PriorizationService();
    }
    
    /**
     * Gerar cronograma automático completo
     */
    public function generate(Cronograma $cronograma)
    {
        // 1. Calcular dias disponíveis
        $diasDisponiveis = $this->calcularDiasDisponiveis($cronograma);
        
        // 2. Calcular horas totais
        $horasTotais = $this->calcularHorasTotais($cronograma);
        $cronograma->total_horas = $horasTotais;
        $cronograma->save();
        
        // 3. Obter tópicos e calcular prioridades
        $topicos = $this->getTopicosParaEstudo($cronograma);
        $topicoPriorizado = $this->priorizationService->priorize($topicos, $cronograma);
        
        // 4. Distribuir horas por tópico
        $alocacao = $this->alocarHoras($topicoPriorizado, $horasTotais);
        
        // 5. Gerar itens do cronograma
        $this->gerarItens($cronograma, $alocacao, $diasDisponiveis);
        
        // 6. Agendar revisões
        $this->agendarRevisoes($cronograma);
        
        return $cronograma;
    }
    
    /**
     * Calcular dias disponíveis para estudo
     */
    private function calcularDiasDisponiveis(Cronograma $cronograma)
    {
        $dataInicio = new \DateTime($cronograma->data_inicio);
        $dataFim = new \DateTime($cronograma->data_fim);
        
        $interval = $dataInicio->diff($dataFim);
        return $interval->days;
    }
    
    /**
     * Calcular total de horas disponíveis
     */
    private function calcularHorasTotais(Cronograma $cronograma)
    {
        // Obtém dados do usuário
        $userModel = new \App\Models\User();
        $user = $userModel->findById($cronograma->user_id);
        
        $diasDisponiveis = $this->calcularDiasDisponiveis($cronograma);
        $horasDia = $user->horas_disponiveis_dia;
        
        return $diasDisponiveis * $horasDia;
    }
    
    /**
     * Obter tópicos que precisam ser estudados
     */
    private function getTopicosParaEstudo(Cronograma $cronograma)
    {
        $topicoModel = new Topico();
        $vestibularModel = new Vestibular();
        
        $vestibular = $vestibularModel->findById($cronograma->vestibular_id);
        
        // Buscar tópicos relevantes para o vestibular
        $query = "
            SELECT t.* FROM TOPICOS t
            JOIN MATERIAS m ON t.materia_id = m.id
            JOIN VESTIB_PESOS vp ON vp.materia_id = m.id
            WHERE vp.vestibular_id = :vestibular_id
            ORDER BY vp.peso DESC, t.dificuldade DESC
        ";
        
        // Implementar execução...
        return [];
    }
    
    /**
     * Alocar horas para cada tópico
     */
    private function alocarHoras($topicos, $horasTotais)
    {
        $totalPeso = array_sum(array_column($topicos, 'peso'));
        
        $alocacao = [];
        
        foreach ($topicos as $topico) {
            $percentual = ($topico['peso'] / $totalPeso) * 100;
            $horasAlocadas = ($percentual / 100) * $horasTotais;
            
            $alocacao[$topico['id']] = [
                'topico' => $topico,
                'horas' => ceil($horasAlocadas)
            ];
        }
        
        return $alocacao;
    }
    
    /**
     * Gerar itens do cronograma (agendamentos diários)
     */
    private function gerarItens($cronograma, $alocacao, $diasDisponiveis)
    {
        $dataAtual = new \DateTime($cronograma->data_inicio);
        $diaAtual = 0;
        
        foreach ($alocacao as $topicoId => $info) {
            $horas = $info['horas'];
            $horasPorBloco = match($cronograma->metodo_estudo) {
                'pomodoro' => $cronograma->duracao_bloco / 60,
                'blocos' => 2,
                default => 1
            };
            
            $blocos = ceil($horas / $horasPorBloco);
            
            for ($i = 0; $i < $blocos; $i++) {
                $item = CronogramaItem::create([
                    'cronograma_id' => $cronograma->id,
                    'topico_id' => $topicoId,
                    'data_prevista' => $dataAtual->format('Y-m-d'),
                    'horas_alocadas' => min($horasPorBloco, $horas),
                    'status' => 'pendente'
                ]);
                
                // Avançar para próximo dia
                $dataAtual->add(new \DateInterval('P1D'));
                if ($dataAtual > new \DateTime($cronograma->data_fim)) {
                    break 2;
                }
            }
        }
    }
    
    /**
     * Agendar revisões espaçadas
     */
    private function agendarRevisoes($cronograma)
    {
        $topicos = $cronograma->getTopicos();
        $revisoModel = new \App\Models\Revisao();
        
        foreach ($topicos as $topico) {
            $revisoModel->create([
                'user_id' => $cronograma->user_id,
                'topico_id' => $topico->id,
                'data_estudo' => date('Y-m-d'),
                'data_proxima_7d' => date('Y-m-d', strtotime('+7 days')),
                'data_proxima_30d' => date('Y-m-d', strtotime('+30 days')),
                'data_proxima_90d' => date('Y-m-d', strtotime('+90 days')),
                'status' => 'pendente'
            ]);
        }
    }
}
```

---

## 3. PADRÃO SERVICE - ALGORITMO DE PRIORIZAÇÃO

```php
<?php
// app/services/PriorizationService.php

namespace App\Services;

class PriorizationService
{
    /**
     * Calcular prioridade usando fórmula
     * 
     * Prioridade = peso_vestibular + dificuldade + erros + dias_sem_revisao
     */
    public function priorize($topicos, $cronograma)
    {
        $erroModel = new \App\Models\Erro();
        $revisoModel = new \App\Models\Revisao();
        
        foreach ($topicos as &$topico) {
            // Peso do vestibular
            $pesoVestibular = $this->getPesoVestibular(
                $topico['id'],
                $cronograma->vestibular_id
            );
            
            // Dificuldade (1-5)
            $dificuldade = $topico['dificuldade'] * 10;
            
            // Frequência de erros
            $frequenciaErros = $erroModel->countByTopico(
                $cronograma->user_id,
                $topico['id']
            );
            
            // Dias desde última revisão
            $diasSemRevisao = $revisoModel->daysSinceReview(
                $cronograma->user_id,
                $topico['id']
            );
            
            // Calcular prioridade
            $topico['prioridade'] = 
                ($pesoVestibular * 20) +
                ($dificuldade * 0.8) +
                ($frequenciaErros * 5) +
                ($diasSemRevisao * 0.5);
        }
        
        // Ordenar por prioridade (descendente)
        usort($topicos, fn($a, $b) => $b['prioridade'] <=> $a['prioridade']);
        
        return $topicos;
    }
    
    private function getPesoVestibular($topicoId, $vestibularId)
    {
        $query = "
            SELECT vp.peso FROM VESTIB_PESOS vp
            JOIN TOPICOS t ON vp.materia_id = t.materia_id
            WHERE t.id = :topico_id AND vp.vestibular_id = :vestibular_id
        ";
        
        // Implementar...
        return 5.0;
    }
}
```

---

## 4. PADRÃO MIDDLEWARE

```php
<?php
// app/middleware/AuthMiddleware.php

namespace App\Middleware;

class AuthMiddleware
{
    public function handle()
    {
        // Verificar se sessão existe
        if (!isset($_SESSION['user_id'])) {
            header('Location: /login');
            exit;
        }
        
        // Verificar timeout
        if (isset($_SESSION['last_activity'])) {
            $timeout = ini_get('session.gc_maxlifetime');
            
            if (time() - $_SESSION['last_activity'] > $timeout) {
                session_destroy();
                header('Location: /login?timeout=1');
                exit;
            }
        }
        
        $_SESSION['last_activity'] = time();
    }
}
```

---

## 5. TRATAMENTO DE ERROS

```php
<?php
// app/exceptions/AuthException.php

namespace App\Exceptions;

class AuthException extends \Exception
{
    public function __construct($message = "Erro de autenticação")
    {
        parent::__construct($message);
    }
}

// Usar
throw new AuthException('Email ou senha inválidos');
```

---

## 6. HELPERS - FUNÇÕES UTILITÁRIAS

```php
<?php
// app/helpers/functions.php

/**
 * Escapar output para HTML (XSS protection)
 */
function escape($string)
{
    return htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
}

/**
 * Gerar CSRF token
 */
function csrfToken()
{
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    
    return $_SESSION['csrf_token'];
}

/**
 * Validar CSRF token
 */
function validateCsrfToken($token)
{
    return isset($_SESSION['csrf_token']) && 
           hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Redirecionar
 */
function redirect($url)
{
    header("Location: {$url}");
    exit;
}

/**
 * Debugar e parar
 */
function dd($var)
{
    echo '<pre>';
    var_dump($var);
    echo '</pre>';
    exit;
}

/**
 * Formatar data para português
 */
function formatDate($date, $format = 'd/m/Y')
{
    return date($format, strtotime($date));
}

/**
 * Formatar número com separador de milhares
 */
function formatNumber($number, $decimals = 2)
{
    return number_format($number, $decimals, ',', '.');
}
```

---

## 7. EXEMPLO COMPLETO: FLUXO DE LOGIN

### 7.1 View (HTML)
```html
<!-- app/views/auth/login.php -->
<form method="POST" action="/login">
    <input type="hidden" name="csrf_token" value="<?= csrfToken() ?>">
    
    <input type="email" name="email" required>
    <input type="password" name="senha" required>
    
    <button type="submit">Login</button>
</form>
```

### 7.2 Controller
```php
public function handleLogin()
{
    // Validar CSRF
    if (!validateCsrfToken($_POST['csrf_token'] ?? '')) {
        return $this->error('CSRF token inválido', null, 403);
    }
    
    // Validar dados
    $rules = [
        'email' => 'required|email',
        'senha' => 'required|min:6'
    ];
    
    $errors = $this->validate($_POST, $rules);
    if (!empty($errors)) {
        return $this->render('auth/login', ['errors' => $errors]);
    }
    
    // Buscar usuário
    $user = User::findByEmail($_POST['email']);
    
    if (!$user || !$user->verifyPassword($_POST['senha'])) {
        return $this->render('auth/login', [
            'error' => 'Email ou senha inválidos'
        ]);
    }
    
    // Criar sessão
    $_SESSION['user_id'] = $user->id;
    $_SESSION['user_name'] = $user->nome;
    
    return redirect('/dashboard');
}
```

---

## 8. CHECKLIST DE QUALIDADE

- ✅ Usar Type Hints (PHP 7+)
- ✅ Documented Methods (PHPDoc)
- ✅ Validar Inputs (Whitelist)
- ✅ Sanitizar Outputs (Escape HTML)
- ✅ Usar Prepared Statements
- ✅ Hash de Senhas (bcrypt)
- ✅ CSRF Protection
- ✅ Rate Limiting
- ✅ Error Handling
- ✅ Logging

---

**Versão:** 1.0  
**Atualizado:** Junho 2026  
