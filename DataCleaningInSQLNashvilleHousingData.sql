

SELECT *
FROM NashvilleHousing

--This only displays the date datatype as date but originally still exists as datetime in the db.
SELECT Convert(date, SaleDate)
FROM NashvilleHousing


--Alter in the db the table column SaleDate datatype from datetime to date
ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate Date;
SELECT SaleDate FROM NashvilleHousing


SELECT * FROM NashvilleHousing
-- WHERE PropertyAddress is NULL
order BY ParcelID


--If you look at the result of the last query before this statement,
--you will see that there are some property address that are NULL
--If you observe line 45 & 46 of the resultant table you will notice an observation on the data
--Sometimes 2 properties can have Unique ID but have similar ParceID and resultantly similar PropertyAddress
--this mean we have infer that for areas where Property Address is NULL its having identical ParceID 
--with another row having a Property Addresss. We can add that Property address to the NUll side of of the other row
--To Solve this, we will have to do a Self-Join of the table to its self.


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b 
 ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------
--Breaking out OwnerAddress into individual columns (address, city, state)

-- SELECT OwnerAddress
-- From NashvilleHousing
-- -- WHERE PropertyAddress is NULL
-- ORDER BY ParcelID


-- SELECT OwnerAddress, CHARINDEX( ',', OwnerAddress)
-- FROM NashvilleHousing 


-- SELECT SUBSTRING(OwnerAddress, 1, CHARINDEX( ',', OwnerAddress) -1) as Address, 
--        SUBSTRING(OwnerAddress, CHARINDEX( ',', OwnerAddress) +1, LEN(OwnerAddress)) as City,
--        PropertyAddress, OwnerAddress
-- FROM NashvilleHousing

--To add and update this to the db, code below.
ALTER TABLE NashvilleHousing
ADD OnwerAdd01 NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OnwerAdd02 NVARCHAR(255)

UPDATE NashvilleHousing
SET OnwerAdd01 = SUBSTRING(OwnerAddress, 1, CHARINDEX( ',', OwnerAddress) -1)

UPDATE NashvilleHousing
SET OnwerAdd02 =  SUBSTRING(OwnerAddress, CHARINDEX( ',', OwnerAddress) +1, LEN(OwnerAddress))


--but we couldnt totally achieve what we aimed to do initially. 
--we will use another SQL function called PARSE to split column by all occurences of each delimeter ','

-- SELECT OwnerAddress, 
--        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
--        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as city,
--        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
-- FROM NashvilleHousing

--Update this into a newly created column in the db table.

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitAddress NVARCHAR(300)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitState NVARCHAR(255)


UPDATE NashvilleHousing
SET OwnerAddressSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerAddressSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT OwnerAddressSplitAddress, OwnerAddressSplitCity, OwnerAddressSplitState
FROM NashvilleHousing
-- WHERE PropertyAddress is NULL
order BY ParcelID


--Change Y and N to YES AND No in "SoldAsVacant" field.

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2


-- SELECT 
--     CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--     WHEN SoldAsVacant = 'N' THEN 'No'
--     ELSE SoldAsVacant
--     END AS CasedSoldAsVacant,
--     COUNT( CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--     WHEN SoldAsVacant = 'N' THEN 'No'
--     ELSE SoldAsVacant
--     END) as CasedCount
-- From NashvilleHousing
-- Group BY 
--     CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--     WHEN SoldAsVacant = 'N' THEN 'No'
--     ELSE SoldAsVacant
--     END

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                    END
SELECT SoldAsVacant, COUNT(SoldAsVacant)
From NashvilleHousing
Group BY SoldAsVacant



--###########################################
--Remove Duplicates 
--Reference Research site https://www.sqlservertutorial.net/sql-server-basics/delete-duplicates-sql-server/


WITH RowNum AS (
SELECT *, ROW_NUMBER() OVER (
          PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                        ORDER BY
                        UniqueID) row_num_01
FROM NashvilleHousing
)
SELECT *
-- DELETE
FROM RowNum
WHERE row_num_01 > 1
-- ORDER BY PropertyAddress






--- Deleting Unused columns



ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
Select * 
From NashvilleHousing