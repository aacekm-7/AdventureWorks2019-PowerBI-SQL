use AdventureWorks2019;

--READ/LEER:
--Muchos de los campos que hay en las vistas de las consultas SQL fueron removidos o correccionadas en Power BI.
--Many of the fields in the SQL query views were removed or corrected in Power BI.


--DIMENSIONES


--DimProduct

CREATE VIEW DimProduct AS
SELECT DISTINCT
    p.ProductID,
    p.Name AS Producto,
    p.ProductNumber,
    CAST(ISNULL(p.Color,'SIN_COLOR') AS VARCHAR(50)) AS Color,
    CAST(ISNULL(p.Size,'SIN_TAMANO') AS VARCHAR(50)) AS Size,
    CAST(ISNULL(p.Weight,0) AS VARCHAR(50)) AS Weight,
    CAST(ISNULL(p.ProductLine,'SIN_LINEA') AS VARCHAR(10)) AS ProductLine,
    CAST(ISNULL(p.Class,'SIN_CLASE') AS VARCHAR(10)) AS Class,
    CAST(ISNULL(p.Style,'SIN_ESTILO') AS VARCHAR(10)) AS Style,
    pm.Name AS ModeloProducto,
    sc.Name AS Subcategoria,
    c.Name AS Categoria
FROM Production.Product p
LEFT JOIN Production.ProductModel pm 
    ON p.ProductModelID = pm.ProductModelID
LEFT JOIN Production.ProductSubcategory sc 
    ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c 
    ON sc.ProductCategoryID = c.ProductCategoryID;


--DimLocation

CREATE VIEW DimLocation AS 
SELECT DISTINCT
    l.LocationID,
    CAST(l.Name AS VARCHAR(100)) AS LocationName,
    CAST(l.CostRate AS VARCHAR(50)) AS CostRate,
    CAST(l.Availability AS VARCHAR(50)) AS Availability
FROM Production.Location l;


--DimCliente

ALTER VIEW DimCliente AS
SELECT DISTINCT
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS Customer,
    a.City,
    sp.Name AS StateProvinceName,
    cr.Name AS CountryRegionName,
    CAST(ISNULL(ea.EmailAddress,'SIN_EMAIL') AS VARCHAR(200)) AS EmailAddress,
    CAST(ISNULL(ph.PhoneNumber,'SIN_TELEFONO') AS VARCHAR(50)) AS PhoneNumber,
    CAST(ISNULL(c.EmailPromotion, 0) AS VARCHAR(10)) AS EmailPromotion
FROM Sales.Customer c
LEFT JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress ea 
    ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone ph 
    ON p.BusinessEntityID = ph.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea 
    ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address a 
    ON bea.AddressID = a.AddressID
LEFT JOIN Person.StateProvince sp 
    ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN Person.CountryRegion cr 
    ON sp.CountryRegionCode = cr.CountryRegionCode;





--DimRRHH

CREATE VIEW DimRRHH AS 
SELECT DISTINCT
    e.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS Empleado,
    CAST(e.JobTitle AS VARCHAR(100)) AS Cargo,
    d.Name AS Departamento,
    e.BirthDate,
    e.HireDate AS FechaContrato,
    CASE WHEN e.CurrentFlag = 1 THEN 'Activo' ELSE 'Inactivo' END AS Activo
FROM HumanResources.Employee e
JOIN Person.Person p 
    ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.EmployeeDepartmentHistory edh 
    ON e.BusinessEntityID = edh.BusinessEntityID
LEFT JOIN HumanResources.Department d 
    ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL;























SELECT 
a.SalesOrderID AS ID, 
a.LineTotal,
b.CurrencyRateID,
c.AverageRate
FROM sales.SalesOrderDetail AS a
INNER JOIN Sales.SalesOrderHeader	AS b 
ON a.SalesOrderID = b.SalesOrderID
INNER JOIN Sales.CurrencyRate AS c
ON b.CurrencyRateID = c.CurrencyRateID;


--Vista Produccion

ALTER VIEW Compras_PowerBI AS 
SELECT 
a.PurchaseOrderID AS  OrdenID,
b.OrderDate AS FechaOrden,
b.ShipDate AS FechaEnvio,
a.DueDate AS FechaVencimiento,
a.ProductID,
d.Name AS Descripcion,
a.OrderQty AS CantidadPedida,
a.ReceivedQty AS CantidadRecibida,
a.RejectedQty AS CantidadDevuelta,
a.UnitPrice AS PrecioUnitario,
a.LineTotal AS MontoTotal,
b.VendorID AS ProveedorID,
e.Name AS Proveedor,
c.AverageLeadTime 
FROM Purchasing.PurchaseOrderDetail AS A
INNER JOIN Purchasing.PurchaseOrderHeader AS B ON a.PurchaseOrderID = b.PurchaseOrderID
INNER JOIN Purchasing.ProductVendor AS C ON a.ProductID = c.ProductID
INNER JOIN Production.Product AS D ON c.ProductID = d.ProductID
INNER JOIN Purchasing.Vendor AS E ON b.VendorID = e.BusinessEntityID;

SELECT VIEW c

--Vista Producción

SELECT COUNT(*) FROM Production.WorkOrder
SELECT * FROM Production.WorkOrder
SELECT * FROM PRODUCTION.WorkOrderRouting
SELECT * FROM Production.Product
SELECT * FROM Production.ProductModel


--CREATE VIEW Producción_PowerBI AS
SELECT 
a.WorkOrderID,
a.StartDate AS FechaInicio,
a.EndDate AS FechaFin,
a.DueDate AS FechaVencimiento,
d.LocationID,
d.Name	AS Location,
b.ProductID,
b.Name AS Producto,
e.ProductModelID,
e.Name AS ProductModel,
a.OrderQty AS Cantidad,
a.StockedQty AS CantidadDisponible,
b.StandardCost AS CostoEstándar,
b.ListPrice AS PrecioDeLista
FROM Production.WorkOrder AS a
INNER JOIN Production.Product AS b ON a.ProductID = b.ProductID
INNER JOIN Production.WorkOrderRouting AS c ON a.WorkOrderID = c.WorkOrderID
INNER JOIN Production.Location AS d ON c.LocationID = d.LocationID
INNER JOIN Production.ProductModel AS e ON b.ProductModelID = e.ProductModelID

--Vista Almacen


SELECT * FROM Production.Product
SELECT * FROM Production.ProductModel
SELECT COUNT(*) FROM Production.ProductInventory
SELECT * FROM Production.ProductInventory

ALTER VIEW Inventario_PowerBI AS --MODIFICACIÓN EL 9/2/2026 | SE AGREGÓ EL CAMPO PRODUCTO LINE
SELECT 
a.ModifiedDate AS FechaEntrada,
a.ProductID,
c.ProductLine,
c.Name AS Producto,
d.ProductModelID,
d.Name AS ModeloProducto,
b.LocationID,
b.Name AS Localidad,
a.Quantity
FROM Production.ProductInventory AS a
INNER JOIN Production.Location AS b ON a.LocationID = b.LocationID
INNER JOIN Production.Product AS c ON a.ProductID = c.ProductID
INNER JOIN Production.ProductModel AS d ON c.ProductModelID = d.ProductModelID

select * from Inventario_PowerBI

--Vista RRHH

--CREATE VIEW RH_PowerBI AS 
SELECT 
a.BusinessEntityID,
a.StartDate AS FechaContrato,
a.EndDate AS FinContrato,
b.GroupName AS Gerencia,
b.Name AS Departamento,
c.FirstName + ' ' + c.LastName as NombreEmpleado,
d.JobTitle,
d.Gender,
d.MaritalStatus,
d.BirthDate
FROM HumanResources.EmployeeDepartmentHistory AS a
INNER JOIN HumanResources.Department AS b ON a.DepartmentID = b.DepartmentID
INNER JOIN Person.Person AS c ON a.BusinessEntityID = c.BusinessEntityID
INNER JOIN HumanResources.Employee AS d ON a.BusinessEntityID = d.BusinessEntityID;

SELECT COUNT(*) AS Transacciones FROM Sales.SalesOrderHeader

SELECT * FROM Sales.SalesOrderHeader
SELECT * FROM Sales.SalesOrderDetail


--Ventas totales por mes y año
SELECT 
 YEAR(T1.OrderDate) AS [Año],
 MONTH(T1.OrderDate) AS [Mes],
 SUM(T2.LineTotal) AS Total
FROM Sales.SalesOrderHeader AS T1
INNER JOIN Sales.SalesOrderDetail AS T2
    ON T1.SalesOrderID = T2.SalesOrderID
GROUP BY 
    YEAR(T1.OrderDate), 
    MONTH(T1.OrderDate) -- Es obligatorio agrupar por las mismas funciones del SELECT
ORDER BY 
    [Año] DESC, 
    [Mes] DESC;


SELECT * FROM Sales.Customer 
WHERE CustomerID = 29818;

SELECT * FROM Sales.SalesOrderDetail
SELECT * FROM Sales.SalesOrderHeader
Select * from sales.Customer


--VERIFICACIÓN DE MONTO RESPECTO A UN GRÁFICO DE DISPERSIÓN EN POWERBI

SELECT 
t1.CustomerID,
SUM(t2.LineTotal) AS Total
FROM Sales.SalesOrderHeader AS t1
INNER JOIN Sales.SalesOrderDetail AS t2
ON t1.SalesOrderID = t2.SalesOrderID
WHERE t1.CustomerID = 29818
GROUP BY t1.CustomerID;









