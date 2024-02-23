/*
Cleaning Data in SQL
*/

SELECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------
--Standardize Date Format
SELECT CONVERT(datetime,Saledate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(datetime, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing
------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
--(have to do self join on ParcelID where already have an address)

SELECT one.ParcelID,one.PropertyAddress, two.parcelID, two.PropertyAddress, ISNULL(one.propertyaddress,two.propertyaddress)
FROM NashvilleHousing one
JOIN NashvilleHousing two
	ON one.ParcelID = two.ParcelID
	AND one.UniqueID <> two.UniqueID
WHERE one.PropertyAddress IS NULL

UPDATE one
SET PropertyAddress = ISNULL(one.propertyaddress,two.propertyaddress)
FROM NashvilleHousing one
JOIN NashvilleHousing two
	ON one.ParcelID = two.ParcelID
	AND one.UniqueID <> two.UniqueID
WHERE one.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------
--Breaking Out Address into Individual Column (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS County
FROM NashvilleHousing


--New Column 1
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

--New Column 2
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Owner Address

SELECT *
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

--New Column 1
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--New Column 2
ALTER TABLE NashvilleHousing
ADD OwnerSplitCounty NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCounty = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--New Column 3
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	ELSE 'No'
	END
FROM NashvilleHousing

--have to convert column type from bit to nvarchar else cannot convert 0/1 to yes/no
ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(255)

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------------------------------------------------
--Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY  ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY UniqueID
					) Row_Num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


SELECT *
FROM RowNumCTE
WHERE row_num > 1


------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN Saledate