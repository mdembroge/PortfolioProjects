/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM PortfolioProject..NashvilleHousingData


--Standardize Date Format


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(date, SaleDate)


--Populate Property Address Data


SELECT *
FROM PortfolioProject..NashvilleHousingData
--WHERE PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


--Dividing Address into Separate Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousingData

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) 

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT *
FROM PortfolioProject..NashvilleHousingData


--Changing Y and N to Yes and No in "Sold as Vacant" Field


SELECT Distinct(SoldasVacant), Count(SoldasVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldasVacant
ORDER BY 2

SELECT SoldasVacant
, CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
    WHEN SoldasVacant = 'N' THEN 'No'
    ELSE SoldasVacant
    END
FROM PortfolioProject..NashvilleHousingData

UPDATE PortfolioProject..NashvilleHousingData
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
    WHEN SoldasVacant = 'N' THEN 'No'
    ELSE SoldasVacant
    END


--Removing Duplicates


WITH RowNumCTE AS(
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
FROM PortfolioProject..NashvilleHousingData
--ORDER BY ParcellID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Deleting Unused Columns


SELECT *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN SaleDate
