/*
Cleaning Data in SQL Queries
*/


SELECT * FROM Portfolio_Project..Nashville_Housing;

  ---------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SalesDateConverted, CONVERT(Date, SaleDate) FROM Portfolio_Project..Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD SalesDateconverted Date;

UPDATE Nashville_Housing
SET SalesDateconverted = CONVERT(Date, SaleDate);

 ----------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT Housing_table1.ParcelID, Housing_table1.PropertyAddress, Housing_table2.ParcelID, Housing_table2.PropertyAddress, ISNULL(Housing_table1.PropertyAddress, Housing_table2.PropertyAddress)
FROM Portfolio_Project..Nashville_Housing AS Housing_table1
JOIN Portfolio_Project..Nashville_Housing AS Housing_table2
ON Housing_table1.ParcelID = Housing_table2.ParcelID
AND Housing_table1.[UniqueID ] <> Housing_table2.[UniqueID ]
WHERE Housing_table1.PropertyAddress IS NULL;

UPDATE Housing_table1
SET PropertyAddress = ISNULL(Housing_table1.PropertyAddress, Housing_table2.PropertyAddress)
FROM Portfolio_Project..Nashville_Housing AS Housing_table1
JOIN Portfolio_Project..Nashville_Housing AS Housing_table2
ON Housing_table1.ParcelID = Housing_table2.ParcelID
AND Housing_table1.[UniqueID ] <> Housing_table2.[UniqueID ]
WHERE Housing_table1.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project..Nashville_Housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City

FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD Propertysplit_Address NVARCHAR(255);

UPDATE Nashville_Housing
SET Propertysplit_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE Nashville_Housing
ADD Propertysplit_City NVARCHAR(255);

UPDATE Nashville_Housing
SET Propertysplit_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT * FROM Portfolio_Project..Nashville_Housing;



SELECT OwnerAddress
FROM Portfolio_Project..Nashville_Housing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project..Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD Ownersplit_Address NVARCHAR(255);

UPDATE Nashville_Housing
SET Ownersplit_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Nashville_Housing
ADD Ownersplit_City NVARCHAR(255);

UPDATE Nashville_Housing
SET Ownersplit_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashville_Housing
ADD Ownersplit_State NVARCHAR(255);

UPDATE Nashville_Housing
SET Ownersplit_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM Portfolio_Project..Nashville_Housing;

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio_Project..Nashville_Housing;

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;


SELECT * FROM Portfolio_Project..Nashville_Housing;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RownumCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM Portfolio_Project..Nashville_Housing
)

SELECT *
FROM RownumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * FROM Portfolio_Project..Nashville_Housing;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * FROM Portfolio_Project..Nashville_Housing;

ALTER TABLE Portfolio_Project..Nashville_Housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

