
/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM [Portfolio Projects].[dbo].[NashvilleHousing];

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saleDate,SaleDateConverted
FROM [Portfolio Projects].[dbo].[NashvilleHousing];


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Drop old field name and rename the new field

SELECT saleDate
FROM [Portfolio Projects].[dbo].[NashvilleHousing];

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [Portfolio Projects].[dbo].[NashvilleHousing]
WHERE PropertyAddress is null
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Projects].[dbo].[NashvilleHousing] a
JOIN [Portfolio Projects].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Projects].[dbo].[NashvilleHousing] a
JOIN [Portfolio Projects].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Portfolio Projects].[dbo].[NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From [Portfolio Projects].[dbo].[NashvilleHousing];


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select PropertyAddress,PropertySplitAddress,PropertySplitCity
From [Portfolio Projects].[dbo].[NashvilleHousing]





Select OwnerAddress
From [Portfolio Projects].[dbo].[NashvilleHousing]


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Projects].[dbo].[NashvilleHousing]



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


Select OwnerAddress,
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState
From [Portfolio Projects].[dbo].[NashvilleHousing];


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Projects].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Projects].[dbo].[NashvilleHousing]


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Projects].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Projects].[dbo].[NashvilleHousing]
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Projects].[dbo].[NashvilleHousing]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Portfolio Projects].[dbo].[NashvilleHousing];


ALTER TABLE [Portfolio Projects].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;