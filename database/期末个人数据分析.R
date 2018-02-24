#数据库万能连接方法
# library(RODBC)
# odbcDataSources()
# setwd("C:/Program Files/Microsoft SQL Server/MSSQL13.MSSQLSERVER/MSSQL/DATA")
# odbcDataSources()
# channel <- odbcConnect("SQL Server client",uid = "sa",pwd = "13600217351")
# tpcds = sqlTables(channel)
# 
# sqlFetch(channel,"customer") #取出表格
# close(channel)


#R版本改成SQL的R版本
connStr <- paste("Driver=SQL Server; Server=", "DESKTOP-R5O5NHN",";Database=", "TPCDS", ";Trusted_Connection=true;", sep = ""); 

#影响商品销售的因素
item_returns <- RxSqlServerData(table = "dbo.item_sales_analysis",connectionString = connStr, returnDataFrame = TRUE); 
i_data <- rxImport(item_returns); 
head(i_data)
summary(i_data)

#销售额聚类,划分商品等级
kc <- kmeans(na.omit(i_data[,c("i_current_price","sales")]), 4); 

#聚类结果可视化  
library(ggplot2)
plot_data = na.omit(i_data[,c("i_current_price","sales")])
plot_data$col = kc$cluster
head(plot_data)
ggplot(plot_data,aes(i_current_price,sales,colour=col))+geom_point()
ggplot(plot_data,aes(x=sales,fill = factor(col)))+geom_density(alpha=.35,colour="grey")

#畅销划分
a1 = aggregate(sales~col,max,data = plot_data)
a2 = aggregate(sales~col,min,data = plot_data)
(a2$sales[order(a1$sales)][-1]+a1$sales[order(a1$sales)][-4])/2





#影响店铺销售因素 R纵向数据分析
store_returns <- RxSqlServerData(table = "dbo.store_sales_analysis",connectionString = connStr, returnDataFrame = TRUE); 
ss_data <- rxImport(store_returns); 
head(ss_data)
pairs(ss_data[,c("avg_price","diversity","customer_flow","return_loss","sales")])
library(nlme)
fm <- lme( sales ~ avg_price + customer_flow, data = ss_data, 
           random = ~ 1|s_store_sk)
summary(fm)
fm$coefficients


