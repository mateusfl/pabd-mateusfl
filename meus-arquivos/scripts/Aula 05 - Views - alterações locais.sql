-- Views materializadas adicionadas localmente.

-- 5. Produtos mais vendidos
drop view if exists v_top_products;
create view v_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

select * from v_top_products order by total_vendido desc;

drop materialized view if exists mv_top_products;
create materialized view mv_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name
with data;

select * from mv_top_products order by total_vendido desc;

-- 6. Total vendido por pedido/mês
drop materialized view if exists mv_monthly_sales;

create materialized view mv_monthly_sales as
select
    o.id,
    to_char(date_trunc('month', o.order_date), 'YYYY-MM') mes,
    sum(o.total) total_vendido
from orders o
group by o.id, mes
order by mes;

select * from mv_monthly_sales;

-- Índice
create unique index idx_mv_monthly_sales_month
on mv_monthly_sales(mes);
