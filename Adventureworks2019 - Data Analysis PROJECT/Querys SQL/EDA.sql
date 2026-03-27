USE northwind;

-- Análisis Exploratorio (EDA)

-- 1. Reconocimiento 

-- Validando la cantidad filas que tiene cada tabla

SELECT COUNT(*) AS Total_registros FROM CUSTOMERS -- 91
SELECT COUNT(*) AS Total_registros FROM Orders -- 830
SELECT COUNT(*) AS Total_registros FROM [Order Details] -- 2155
SELECT COUNT(*) AS Total_registros FROM Products -- 77
SELECT COUNT(*) AS Total_registros FROM Categories -- 8
SELECT COUNT(*) AS Total_registros FROM Suppliers -- 29
SELECT COUNT(*) AS Total_registros FROM Employees -- 9
SELECT COUNT(*) AS Total_registros FROM Shippers -- 3

-- 2. Calidad de los datos

-- Verificando si hay datos nulos en columnas esenciales

SELECT * FROM Orders WHERE OrderDate IS NULL 
							AND ShippedDate IS NULL; -- No hay nulos en campos de fechas

SELECT * FROM [Order Details] WHERE UnitPrice IS NULL  
                              AND Quantity IS NULL 
                              AND Discount IS NULL; -- No hay nulos 

-- Validando si hay duplicados en los IDs

SELECT 
    CASE 
        WHEN COUNT(OrderID) = COUNT(DISTINCT OrderID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS Resultado
FROM Orders; -- No hay duplicados


SELECT 
    CASE 
        WHEN COUNT(OrderID) = COUNT(DISTINCT OrderID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS Resultado
FROM [Order Details]; -- Hay duplicados*. Los duplicados que observamos en el ID de esta tabla OrderDetails es porque,
                      -- Está compuesta con ProductID.

SELECT * FROM [Order Details]


SELECT 
    CASE 
        WHEN COUNT(CustomerID) = COUNT(DISTINCT CustomerID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Customers; -- No hay duplicados

SELECT 
    CASE
        WHEN COUNT(ProductID) = COUNT(DISTINCT ProductID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Products; -- No hay duplicados

SELECT
    CASE 
        WHEN COUNT(EmployeeID) = COUNT(DISTINCT EmployeeID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Employees; -- No hay duplicados

SELECT
    CASE 
        WHEN COUNT(ShipperID) = COUNT(DISTINCT ShipperID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Shippers; -- No hay duplicados

SELECT
    CASE 
        WHEN COUNT(SupplierID) = COUNT(DISTINCT SupplierID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Suppliers -- No hay duplicados

SELECT
    CASE 
        WHEN COUNT(CategoryID) = COUNT(DISTINCT CategoryID) THEN 'No hay duplicados'
        ELSE 'Hay duplicados'
    END AS resultado
FROM Categories; -- No hay duplicados

-- Validando que no hayan anomalías en precios y cantidades

SELECT * FROM [Order Details] WHERE UnitPrice <= 0; -- No se encontraron datos incorrectos

SELECT * FROM [Order Details] WHERE Quantity <= 0; -- No se encontraron datos incorrectos

SELECT * FROM [Order Details] WHERE Discount >= 100; -- No se encontraron datos incorrectos

SELECT * FROM Orders;

-- La fecha de orden no puede ser más que la fecha de envío

SELECT OrderID, OrderDate, ShippedDate
FROM Orders
WHERE ShippedDate IS NOT NULL
AND OrderDate > ShippedDate; -- No se dectetaron anomalías

-- 3.1 Análisis de las tablas clave

-- ORDENES

-- Validando la primera orden de la empresa (a nivel de fecha)
SELECT MIN(OrderDate) FROM Orders

-- Ordenes totales por fecha

SELECT 
       COUNT(*) AS OrdenesTotales,
       MIN(OrderDate) AS FechaPedido,
       MAX(ShippedDate) AS FechaEnvío,
    CASE 
        WHEN ShippedDate IS NULL THEN 'Pedido en cola'
        ELSE 'Entregado'
    END AS EstadoPedido
FROM Orders
    WHERE OrderDate >= '1996-07-04' AND OrderDate <= '1998-05-06'
GROUP BY ShippedDate,
    CASE    
        WHEN OrderDate IS NULL THEN 'Pedido en cola'
        ELSE 'Entregado'
    END
ORDER BY EstadoPedido;

-- Ordenes totales

SELECT COUNT(*) AS OrdenesTotales FROM Orders; -- 830

-- Promedio de productos por orden

SELECT AVG(suma_cantidad) AS  promedio_unidades_por_orden
FROM (
     SELECT OrderID, SUM(Quantity) AS suma_cantidad
     FROM [Order Details]
     GROUP BY OrderID
    ) AS subconsulta; -- 61 productos promedio por orden

-- CLIENTES

-- Distribución por país

SELECT COUNT(*) AS TotalClientes, Country FROM Customers
GROUP BY Country
ORDER BY TotalClientes DESC

-- Distribución por ciudad

SELECT COUNT(*) AS TotalClientes, City FROM Customers
GROUP BY City
ORDER BY TotalClientes DESC

-- PRODUCTOS

-- Cuantos productos hay por categoría

SELECT 
    COUNT(p.ProductID) AS Productos,
    c.CategoryName AS Categoria
FROM Products AS p
INNER JOIN Categories AS c
ON p.CategoryID = c.CategoryID
GROUP BY CategoryName
ORDER BY Productos DESC;

-- Productos descontinuados

SELECT 
    ProductName,
    CASE
        WHEN Discontinued = 0 THEN 'Producto en stock' 
        ELSE 'Producto descontinuado' 
    END AS ProductosStock
FROM Products;

SELECT * FROM Employees

SELECT * FROM Products WHERE Discontinued = 1; -- 8 productos descontinuados

-- EMPLEADOS

-- Cuantas ordenes gestionó cada empleado

SELECT 
    e.EmployeeID,
    e.FirstName AS Nombre,
    COUNT(o.OrderID) AS OrdenesTotales
FROM Orders AS o
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName
ORDER BY OrdenesTotales DESC; -- Margaret es la empleada que más ha vendido (156)

-- Distribución por región

SELECT 
    e.EmployeeID,
    e.FirstName AS Nombre,
    COUNT(o.OrderID) AS OrdenesRealizadas,
    o.ShipCountry AS País
FROM Orders AS o
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, o.ShipCountry
ORDER BY OrdenesRealizadas DESC; -- Alemania es el país donde más la empresa ha vendido

-- ENVÍOS

-- Ordenes no enviadas

SELECT COUNT(*) AS OrdenesPendientes
FROM Orders
WHERE ShippedDate IS NULL; -- 21 ordenes pendientes 

-- SUPLIDORES

-- Proveedores por país

SELECT COUNT(SupplierID) TotalProveedores,  Country  AS País
FROM Suppliers
GROUP BY Country
ORDER BY TotalProveedores DESC; -- USA es donde más la empresa tiene proveedores

-- Cantidad de productos por proveedor

SELECT * FROM Suppliers
SELECT * FROM Products

SELECT 
    s.SupplierID,
    s.CompanyName AS Proveedor,
    COUNT(p.ProductID) AS TotalProductos
FROM Suppliers AS s 
INNER JOIN Products AS p
ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY TotalProductos DESC;

-- 5. ANÁLISIS DE NEGOCIO


SELECT * FROM [Order Details]

SELECT
    OrderID,
    ProductID,
    UnitPrice,
    Quantity,
    Discount,
    SUM(UnitPrice * Quantity) * (1 - Discount) AS IngresoReal
FROM [Order Details]
GROUP BY OrderID, ProductID, UnitPrice, Quantity, Discount;


-- Crecimiento de ventas mes a mes

WITH CrecimientoVentas AS (
    SELECT
    SUM(od.UnitPrice * Quantity * (1 - Discount)) AS Ingreso,
    YEAR(OrderDate) AS Año,
    MONTH(OrderDate) AS Mes
    FROM [Order Details] AS od
    INNER JOIN Orders AS o
    ON od.OrderID = o.OrderID
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
)
SELECT Año, Mes, Ingreso FROM CrecimientoVentas
ORDER BY Año ASC;

-- Años con más ingresos

SELECT 
    SUM(od.UnitPrice * Quantity * (1 - od.Discount)) AS IngresoTotal,
    YEAR(OrderDate) AS Año
FROM [Order Details] AS od
INNER JOIN Orders AS o
ON od.OrderID = o.OrderID
GROUP BY YEAR(OrderDate)
ORDER BY IngresoTotal DESC; -- 1997 siendo el con más ingresos
        

-- Venta promedio ponderada

WITH VentaPromedioPonderada AS (
    SELECT
    YEAR(o.OrderDate) AS Año,
    SUM(od.UnitPrice * od.Quantity * (1 - od.discount)) AS IngresosTotales,
    SUM(od.UnitPrice * od.Quantity * (1 - od.discount)) / SUM (od.Quantity) AS VentaPromedioPonderada
    FROM [Order Details] AS od
    INNER JOIN Orders AS o
    ON od.OrderID = o.OrderID
    GROUP BY YEAR(o.OrderDate)
)
SELECT * FROM VentaPromedioPonderada
ORDER BY IngresosTotales DESC; -- Visualizamos que en el 1998 fue donde mejor venta promedio ponderada tuvo el negocio


SELECT * FROM [Order Details] WHERE OrderID = 10981








