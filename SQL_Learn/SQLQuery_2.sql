
SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data
SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] b 
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] b 
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

-- Breaking out Address into Individual Columns (Address, City, State)
-- 1. 
SELECT PropertyAddress
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity nvarchar(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

-- 2. 
SELECT OwnerAddress
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

SELECT
PARSENAME(REPLACE(OwnerAddress,',' ,'.'),3)
, PARSENAME(REPLACE(OwnerAddress,',' ,'.'),2)
, PARSENAME(REPLACE(OwnerAddress,',' ,'.'),1)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

-- Address
ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress nvarchar(255);
UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' ,'.'),3)

-- City
ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity nvarchar(255);
UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' ,'.'), 2)

-- State
ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState nvarchar(255);
UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' ,'.'), 1)

SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

UPDATE [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END


-- Remove Duplicates
WITH RowNumCTE As(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                 UniqueID
    ) row_num
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 
--ORDER BY ParcelID
)
SELECT * -- use DELETE to delete duplicate and use SELECT to check whether success
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] 

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning] 
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning] 
DROP COLUMN  SaleDate





