# Modelagem de Banco de Dados para E-commerce

## Diagrama de Entidade-Relacionamento (ER)
![modelagem_projeto_logico_melhorado_v3](https://github.com/user-attachments/assets/fb2fdf90-bb17-4199-8109-ee5ea1b7b325)


## Principais Funcionalidades
- Cadastro de clientes PJ/PF
- Múltiplos métodos de pagamento
- Rastreamento de entregas
- Gestão de estoque integrada
- Relacionamento fornecedores-produtos

## Como Executa


2. Execute o script SQL:
```bash
mysql -u usuario -p < ecommerce.sql
```

3. Teste as queries:
```bash
mysql -u usuario -p ecommerce < queries.sql
```

## Estrutura do Banco
```sql
-- Exemplo de tabela
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('PF', 'PJ') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Queries Exemplo
```sql
-- Pedidos por cliente
SELECT client_id, COUNT(*) FROM orders GROUP BY client_id;
```

## Contribuição
Contribuições são bem-vindas! Siga o padrão de código existente.
