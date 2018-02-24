-- ʵ������۶�Ӱ�����ط�����
-- ��Ҫ��������ƽ�����ۼ۸�������Ʒ���࣬�˻��������ٹ˿����ȶ����۶��Ӱ��
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


-- �˿ͷ���:������ͬ����Ŀͻ��������͹�����Ʒ����Ĳ�ͬ

--���ݹ˿���࣬�������۶�Ҳ��࣬���˾����׺�GA���
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



-- ʵ����������������ͳ��6��ʵ���ÿ�������۶�����󣬷�������Խ�࣬����Խ��
select s_store_sk,d_year,d_date,
sum(ss_sales_price*ss_quantity) as sales,sum(ss_net_profit*ss_quantity) as profits
into store_sales_analysis2
from store,store_sales,date_dim
where s_store_sk=ss_store_sk
and ss_sold_date_sk=d_date_sk
group by s_store_sk,d_year,d_date
order by  d_year,s_store_sk desc --��7��1�ҵ�������࣬�������

-- ʵ������۵����ʱ��������ֱ�ͳ��һ���У�һ���У�һ����������õ�ʱ��Σ����ŵ������ṩ���顣
select top 100 d_qoy,d_moy,d_day_name,t_hour, --���ļ���12��
sum(ss_sales_price*ss_quantity) as sales
into store_time_analysis
from date_dim,time_dim,store_sales
where ss_sold_date_sk=d_date_sk
and ss_sold_time_sk=t_time_sk
group by d_qoy,d_moy,d_day_name,t_hour
order by sales desc

--	��Ʒ����Ӱ�����ط�������Ҫ����������Ʒ��Ʒ�ƣ����Ŀ¼����ɫ������ȡ�
select i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price,
sum(ss_sales_price*ss_quantity) as sales
into item_sales_analysis
from item,store_sales
where i_item_sk=ss_item_sk
group by i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price
order by i_item_sk,i_brand,i_class,i_category,i_size,i_color,i_current_price
 