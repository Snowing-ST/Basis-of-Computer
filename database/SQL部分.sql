-- 实体店销售额影响因素分析。
-- 主要分析区域，平均销售价格，销售商品种类，退货数，光临顾客数等对销售额的影响
select s_store_sk,d_year,d_moy,s_city,s_state,
sum(cast(ss_sales_price*ss_quantity as bigint))/sum(cast(ss_quantity as bigint)) as avg_price,
count(ss_item_sk) as diversity,count(ss_customer_sk) as customer_flow,
sum(cast(sr_net_loss as bigint)) as return_loss,
sum(cast(ss_sales_price*ss_quantity as bigint)) as sales
into store_sales_analysis
from store,store_sales,store_returns,date_dim,promotion
where s_store_sk=ss_store_sk
and ss_sold_date_sk=d_date_sk
and s_store_sk=sr_store_sk
and d_date_sk=sr_returned_date_sk
group by s_store_sk,d_year,d_moy,s_city,s_state
order by  s_store_sk,d_year,d_moy,s_city,s_state


-- 顾客分析:分析不同地域的客户，购买额和购买商品种类的不同

--德州顾客最多，贡献销售额也最多，但人均贡献和GA差不多
select ca_state ,count(c_customer_sk) as customer_count,
avg(ss_sales_price*ss_quantity) as avg_comtri_buy,
sum(ss_sales_price*ss_quantity) as comtri_buy,
count(ss_item_sk) as item_kinds
into customer_analysis
from customer,customer_address,store_sales
where c_current_addr_sk=ca_address_sk
and c_customer_sk=ss_customer_sk
group by ca_state
order by count(c_customer_sk) desc



-- 实体店销售情况分析。统计6家实体店每年年销售额，年利润，发现卖得越多，亏损越多
select s_store_sk,d_year,d_date,
sum(ss_sales_price*ss_quantity) as sales,sum(ss_net_profit*ss_quantity) as profits
into store_sales_analysis2
from store,store_sales,date_dim
where s_store_sk=ss_store_sk
and ss_sold_date_sk=d_date_sk
group by s_store_sk,d_year,d_date
order by  d_year,s_store_sk desc --第7第1家店销售最多，亏损最多

-- 实体店销售的最佳时间分析。分别统计一天中，一周中，一年中销售最好的时间段，给门店销售提供建议。
select top 100 d_qoy,d_moy,d_day_name,t_hour, --第四季度12月
sum(ss_sales_price*ss_quantity) as sales
into store_time_analysis
from date_dim,time_dim,store_sales
where ss_sold_date_sk=d_date_sk
and ss_sold_time_sk=t_time_sk
group by d_qoy,d_moy,d_day_name,t_hour
order by sales desc

--	商品畅销影响因素分析。主要分析畅销商品的品牌，类别，目录，颜色，尺码等。
select i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price,
sum(ss_sales_price*ss_quantity) as sales
into item_sales_analysis
from item,store_sales
where i_item_sk=ss_item_sk
group by i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price
order by i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price
 