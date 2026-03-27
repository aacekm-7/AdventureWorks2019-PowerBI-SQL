-- ============================================================
-- EDA - AdventureWorks2019
-- Análisis Exploratorio de Datos (Exploratory Data Analysis)
-- ============================================================

USE AdventureWorks2019;

-- ============================================================
-- 1. VOLUMEN DE DATOS — ¿Cuántos registros tiene cada tabla?
-- ============================================================

SELECT 'Clientes'            AS Tabla, COUNT(*) AS TotalRegistros FROM Sales.Customer
UNION ALL
SELECT 'Órdenes de Venta',               COUNT(*) FROM Sales.SalesOrderHeader
UNION ALL
SELECT 'Detalle de Órdenes',             COUNT(*) FROM Sales.SalesOrderDetail
UNION ALL
SELECT 'Productos',                      COUNT(*) FROM Production.Product
UNION ALL
SELECT 'Empleados',                      COUNT(*) FROM HumanResources.Employee
UNION ALL
SELECT 'Órdenes de Compra',              COUNT(*) FROM Purchasing.PurchaseOrderHeader
UNION ALL
SELECT 'Inventario',                     COUNT(*) FROM Production.ProductInventory
UNION ALL
SELECT 'Órdenes de Producción',          COUNT(*) FROM Production.WorkOrder;


-- ============================================================
-- 2. VALORES NULOS — ¿Dónde están los huecos reales?
-- ============================================================

-- Productos: campos que el proyecto imputó con ISNULL
SELECT
    COUNT(*)                                        AS TotalProductos,
    SUM(CASE WHEN Color       IS NULL THEN 1 END)  AS Color_Nulo,
    SUM(CASE WHEN Size        IS NULL THEN 1 END)  AS Size_Nulo,
    SUM(CASE WHEN Weight      IS NULL THEN 1 END)  AS Weight_Nulo,
    SUM(CASE WHEN ProductLine IS NULL THEN 1 END)  AS ProductLine_Nulo,
    SUM(CASE WHEN Class       IS NULL THEN 1 END)  AS Class_Nulo,
    SUM(CASE WHEN Style       IS NULL THEN 1 END)  AS Style_Nulo
FROM Production.Product;

-- Clientes: email y teléfono nulos
SELECT
    COUNT(*)                                                  AS TotalClientes,
    SUM(CASE WHEN ea.EmailAddress  IS NULL THEN 1 END)       AS SinEmail,
    SUM(CASE WHEN ph.PhoneNumber   IS NULL THEN 1 END)       AS SinTelefono
FROM Sales.Customer c
LEFT JOIN Person.Person p         ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress ea  ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone ph   ON p.BusinessEntityID = ph.BusinessEntityID;


-- ============================================================
-- 3. UNICIDAD / DUPLICADOS — ¿Los IDs son únicos?
-- ============================================================

-- Verifica si hay CustomerID duplicados en la tabla base
SELECT CustomerID, COUNT(*) AS Apariciones
FROM Sales.Customer
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Verifica si hay ProductID duplicados
SELECT ProductID, COUNT(*) AS Apariciones
FROM Production.Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Verifica si hay SalesOrderID duplicados en el header
SELECT SalesOrderID, COUNT(*) AS Apariciones
FROM Sales.SalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. RANGO TEMPORAL — ¿Qué periodo cubren los datos?
-- ============================================================

SELECT
    MIN(OrderDate)  AS FechaMinima,
    MAX(OrderDate)  AS FechaMaxima,
    DATEDIFF(YEAR, MIN(OrderDate), MAX(OrderDate)) AS AñosCubiertos
FROM Sales.SalesOrderHeader;

SELECT
    MIN(OrderDate)  AS CompraMinima,
    MAX(OrderDate)  AS CompraMaxima
FROM Purchasing.PurchaseOrderHeader;

SELECT
    MIN(StartDate)  AS ProduccionMinima,
    MAX(EndDate)    AS ProduccionMaxima
FROM Production.WorkOrder;


-- ============================================================
-- 5. ESTADÍSTICAS NUMÉRICAS — Ventas, precios y cantidades
-- ============================================================

-- Estadísticas de montos de venta por orden
SELECT
    MIN(LineTotal)                   AS VentaMinima,
    MAX(LineTotal)                   AS VentaMaxima,
    AVG(LineTotal)                   AS VentaPromedio,
    SUM(LineTotal)                   AS VentaTotal,
    COUNT(*)                         AS TotalLineas
FROM Sales.SalesOrderDetail;

-- Estadísticas de precios de productos
SELECT
    MIN(ListPrice)   AS PrecioMin,
    MAX(ListPrice)   AS PrecioMax,
    AVG(ListPrice)   AS PrecioPromedio,
    COUNT(*)         AS TotalProductos
FROM Production.Product
WHERE ListPrice > 0; -- Excluye productos sin precio asignado

-- Estadísticas de cantidades en órdenes de compra
SELECT
    MIN(OrderQty)    AS CantidadMin,
    MAX(OrderQty)    AS CantidadMax,
    AVG(OrderQty)    AS CantidadPromedio
FROM Purchasing.PurchaseOrderDetail;


-- ============================================================
-- 6. DISTRIBUCIÓN CATEGÓRICA — ¿Qué hay en los campos clave?
-- ============================================================

-- Productos por categoría
SELECT c.Name AS Categoria, COUNT(*) AS TotalProductos
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c     ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY c.Name
ORDER BY TotalProductos DESC;

-- Clientes por país
SELECT cr.Name AS Pais, COUNT(DISTINCT c.CustomerID) AS TotalClientes
FROM Sales.Customer c
LEFT JOIN Person.Person p                  ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address a                 ON bea.AddressID = a.AddressID
LEFT JOIN Person.StateProvince sp          ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN Person.CountryRegion cr          ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalClientes DESC;

-- Empleados por departamento
SELECT d.Name AS Departamento, COUNT(*) AS TotalEmpleados
FROM HumanResources.EmployeeDepartmentHistory edh
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY TotalEmpleados DESC;

-- Empleados activos vs inactivos
SELECT
    CASE WHEN CurrentFlag = 1 THEN 'Activo' ELSE 'Inactivo' END AS Estado,
    COUNT(*) AS Total
FROM HumanResources.Employee
GROUP BY CurrentFlag;


-- ============================================================
-- 7. OUTLIERS / ANOMALÍAS — Valores extremos
-- ============================================================

-- Órdenes con montos por encima del percentil 99 (atípicamente altos)
SELECT TOP 10
    SalesOrderID,
    SUM(LineTotal) AS TotalOrden
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY TotalOrden DESC;

-- Productos con precio de lista = 0 (posible error de datos)
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice = 0
ORDER BY Name;

-- Órdenes de compra donde cantidad recibida > cantidad pedida
SELECT
    PurchaseOrderID,
    ProductID,
    OrderQty,
    ReceivedQty,
    ReceivedQty - OrderQty AS Diferencia
FROM Purchasing.PurchaseOrderDetail
WHERE ReceivedQty > OrderQty
ORDER BY Diferencia DESC;


-- ============================================================
-- 8. INTEGRIDAD REFERENCIAL — ¿Los JOINs tienen huérfanos?
-- ============================================================

-- Clientes sin persona asociada
SELECT COUNT(*) AS ClientesSinPersona
FROM Sales.Customer
WHERE PersonID IS NULL;

-- Órdenes de venta sin cliente válido
SELECT COUNT(*) AS OrdenesSinCliente
FROM Sales.SalesOrderHeader soh
LEFT JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- Productos en inventario sin modelo de producto
SELECT COUNT(*) AS ProductosSinModelo
FROM Production.Product
WHERE ProductModelID IS NULL;

-- Órdenes de trabajo sin routing (sin ubicación asignada)
SELECT COUNT(*) AS WorkOrdersSinRouting
FROM Production.WorkOrder wo
LEFT JOIN Production.WorkOrderRouting wor ON wo.WorkOrderID = wor.WorkOrderID
WHERE wor.WorkOrderID IS NULL;
