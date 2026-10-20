-- cria o banco de dados
create database aeronautica_db;

-- seleciona o banco de dados
use aeronautica_db;

-- cria a tabela de materiais
create table materiais
(
    id int primary key identity(1,1),
    nome varchar(250) not null,
    descricao text,
    medida varchar(25) not null,
    estoque_minimo int default 0,
    ativo int not null default 1
);

-- consulta a tabela
select * from materiais;

-- cria a tabela de fornecedores
create table fornecedores
(
    id int primary key identity(1,1),
    nome varchar(250) not null,
    contato varchar(250),
    telefone varchar(25),
    ativo int not null default 1
);

-- consulta a tabela
select * from fornecedores;

-- cria a tabela de entrada de materiais
create table entradas
(
    id int primary key identity(1,1),
    id_material int not null,
    id_fornecedor int not null,
    data_entrada date not null,
    quantidade int not null,
    preco decimal(10,2) not null,
    nota_fiscal varchar(50),

    foreign key (id_material) references materiais(id),
    foreign key (id_fornecedor) references fornecedores(id)
);

-- cria a tabela de saida de materiais
create table saidas
(
    id int primary key identity(1,1),
    id_material int not null,
    data_saida date not null,
    quantidade int not null,
    destino varchar(50),

    foreign key (id_material) references materiais(id)
);

-- consulta as tabelas
select * from entradas;
select * from saidas;

-- importa os dados do arquivo materiais.csv
bulk insert materiais
from 'C:\SENAI\materiais.csv'
with
(
    firstrow = 2,
    fieldterminator = ';',
    rowterminator = '0x0a',
    codepage = '65001',
    keepidentity
);

-- consulta os materiais importados
select * from materiais;

-- importa os dados do arquivo fornecedores.csv
bulk insert fornecedores
from 'C:\SENAI\fornecedores.csv'
with
(
    firstrow = 2,
    fieldterminator = ';',
    rowterminator = '0x0a',
    codepage = '65001',
    keepidentity
);

-- consulta os fornecedores importados
select * from fornecedores;

-- cria o procedimento para registrar a entrada de materiais
create procedure registrar_entrada
    @p_id_material int,
    @p_id_fornecedor int,
    @p_data_entrada date,
    @p_quantidade int,
    @p_preco decimal(10,2),
    @p_nota_fiscal varchar(50)
as
begin
    insert into entradas
    (id_material, id_fornecedor, data_entrada, quantidade, preco, nota_fiscal)
    values
    (@p_id_material, @p_id_fornecedor, @p_data_entrada, @p_quantidade, @p_preco, @p_nota_fiscal);
end;

-- registra a entrada de 3 materiais
exec registrar_entrada 1, 1, '2023-10-25', 100, 5.50, 'NF001';

exec registrar_entrada 2, 2, '2023-10-26', 50, 12.00, 'NF002';

exec registrar_entrada 7, 7, '2023-10-27', 40, 18.90, 'NF150';

-- consulta as entradas cadastradas
select * from entradas;

-- cria o procedimento para registrar a saida de materiais
create procedure registrar_saida
    @p_id_material int,
    @p_data_saida date,
    @p_quantidade int,
    @p_destino varchar(50)
as
begin
    insert into saidas
    (id_material, data_saida, quantidade, destino)
    values
    (@p_id_material, @p_data_saida, @p_quantidade, @p_destino);
end;

-- registra a saida de 2 materiais
exec registrar_saida 3, '2023-11-01', 50, 'OP003';

exec registrar_saida 6, '2023-11-05', 20, 'OP010';

-- consulta as saidas cadastradas
select * from saidas;

-- cria o procedimento para inativar materiais
create procedure inativar_material
    @p_id_material int
as
begin
    update materiais
    set ativo = 0
    where id = @p_id_material;
end;

-- inativa 2 materiais
exec inativar_material 4;

exec inativar_material 10;

-- consulta os materiais
select * from materiais;

-- cria o procedimento para inativar fornecedores
create procedure inativar_fornecedor
    @p_id_fornecedor int
as
begin
    update fornecedores
    set ativo = 0
    where id = @p_id_fornecedor;
end;


-- inativa 2 fornecedores
exec inativar_fornecedor 4;

exec inativar_fornecedor 10;

-- consulta os fornecedores
select * from fornecedores;

-- cria a funcao para calcular o estoque
create function calcular_estoque
(
    @p_id_material int
)
returns int
as
begin
    declare @total_entradas int = 0;
    declare @total_saidas int = 0;

    -- calcula o total de entradas
    select @total_entradas = isnull(sum(quantidade), 0)
    from entradas
    where id_material = @p_id_material;

    -- calcula o total de saidas
    select @total_saidas = isnull(sum(quantidade), 0)
    from saidas
    where id_material = @p_id_material;

    -- retorna o estoque atual
    return @total_entradas - @total_saidas;
end;

-- calcula o estoque de 3 materiais
select dbo.calcular_estoque(1) as estoque_material_1;

select dbo.calcular_estoque(2) as estoque_material_2;

select dbo.calcular_estoque(7) as estoque_material_7;

-- cria uma view para consultar o estoque geral
create view consultar_estoque
as
select
    id,
    nome,
    medida,
    estoque_minimo,
    dbo.calcular_estoque(id) as estoque_atual
from materiais;

-- consulta o estoque de todos os materiais
select * from consultar_estoque
order by nome asc;

-- consulta os dados de entrada
select * from entradas;

-- consulta os dados de saida
select * from saidas;