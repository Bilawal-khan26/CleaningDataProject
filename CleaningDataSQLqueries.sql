

--select * 
--from HousingDataCleaning..Sheet1$

--select saleDate 
--from HousingDataCleaning..Sheet1$

/*
-- cleaning data sql queries

*/

select *
from HousingDataCleaning..Sheet1$


--------------------------------------------------------------------------------------
--standardrize Date Formate 

Select SaleDateConverted, CONVERT(date, SaleDate)
from HousingDataCleaning..Sheet1$

Update Sheet1$
Set saleDate = CONVERT(date,SaleDate)

ALTER TABLE Sheet1$
Add SaleDateConverted Date;

Update Sheet1$
SET SaleDateConverted = CONVERT(date, SaleDate)

--------------------------------------------------------------

--Populate property address data

select *
from HousingDataCleaning..Sheet1$
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingDataCleaning..Sheet1$ a
JOIN HousingDataCleaning..Sheet1$ b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingDataCleaning..Sheet1$ a
JOIN HousingDataCleaning..Sheet1$ b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------

--Breaking out address into individual colums (Address,city,state)

select PropertyAddress
from HousingDataCleaning..Sheet1$

select
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', propertyAddress) +1 , LEN(propertyAddress)) as Address
from HousingDataCleaning..Sheet1$

ALTER TABLE Sheet1$
Add PropertySplitAddress Nvarchar(255);

Update Sheet1$
SET PropertySplitAddress = SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress) -1)

ALTER TABLE Sheet1$
Add PropertySplitCity Nvarchar(255);

Update Sheet1$
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', propertyAddress) +1, LEN(propertyAddress)) 

select *
from HousingDataCleaning..Sheet1$


select OwnerAddress
from HousingDataCleaning..Sheet1$

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from HousingDataCleaning..Sheet1$



ALTER TABLE Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update Sheet1$
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Sheet1$
Add OwnerSplitState Nvarchar(255);

Update Sheet1$
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from HousingDataCleaning..Sheet1$
---------------------------------------------------------------------------

--change Y and N to YES and NO in "Sold as Vacant" field


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from HousingDataCleaning..Sheet1$
Group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'YES'
       when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
from HousingDataCleaning..Sheet1$


Update Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
       when SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

----------------------------------------------------------------------------------------------------------------

--Remove duplicates and unused columns
with RownumCTE AS(
select * ,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				       UniqueID
					   ) row_num
from HousingDataCleaning..Sheet1$
--order by ParcelID
)
select *
from RownumCTE
where row_num > 1
--order  by PropertyAddress

----------------------------------------------------------------------------------------------------------

-- unused columns remove


select *
from HousingDataCleaning..Sheet1$


ALTER TABLE HousingDataCleaning..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress



ALTER TABLE HousingDataCleaning..Sheet1$
DROP COLUMN SaleDate


