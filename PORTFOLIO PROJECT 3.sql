--DATA CLEANING WITH SEQUEL
/* Data cleaning also known as data cleansing is the process of detecting and correcting inacccurate or duplicate records
in a database. It is one of the most important parts of a data analysis before analysis can be made it is essential that
the data undergo data cleaning else it may lead to wrong analysis and result which lead to bad decision*/


SELECT *
FROM [House Details]..[house details data]



/*CLEANING OF PROPERTY ADRESS DATA
Populating the Property Address with another property address with the same ParcelID Since house with the same 
PercelID tends to have the same PropertyAddress */
SELECT  * --PropertyAddress
FROM [House Details]..[house details data]
ORDER BY ParcelID

--POPULATING THE PROPERTY ADDRESS
SELECT  a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [House Details]..[house details data] a
JOIN [House Details]..[house details data] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [House Details]..[house details data] a
JOIN [House Details]..[house details data] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress IS NULL
 
 --DONE
 --FOR CONFIRMATION
 SELECT  *
FROM [House Details]..[house details data]
WHERE PropertyAddress IS NULL /* EMPTY? CORRECT*/


--BREKING THE PROPERTY ADDRESS INTO ADDRESS AND CITY.
SELECT  
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress)) AS City
FROM [House Details]..[house details data]

--ADDING THEM INTO THE TABLE
ALTER TABLE [house details data]
ADD PropertySplitAddress nvarchar(255);

UPDATE  [house details data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [house details data]
ADD PropertySplitCity nvarchar(255);

UPDATE  [house details data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress))


--CONFIRMATION
SELECT *
FROM [House Details]..[house details data]





--CLEANING OF OWNER ADDRESS 
-- NOTE OWNER ADDRESS AND PROPERTY ADDRESS ARE NOT THE SAME IN ALL CASES
-- THERE ARE 31055 MISSING 0WNER'S ADDRESS

SELECT count(*)-count(ownerAddress) AS MissingAddree
FROM [House Details]..[house details data]
/*SELECT SUM(CASE WHEN OwnerAddress IS NULL THEN 1 ELSE 0 END) AS [NumberOf Null]
FROM [House Details]..[house details data]*/


SELECT ownerAddress
FROM [House Details]..[house details data]





--SPILITING THE OWNER'S ADDRESS TO ADDRESS, CITY AND STATECODE
SELECT
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
FROM [House Details]..[house details data]


ALTER TABLE [house details data]
ADD OwnerSplitAddress nvarchar(255)

UPDATE  [house details data]
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE [house details data]
ADD OwnerSplitCity nvarchar(255);

UPDATE  [house details data]
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE [house details data]
ADD OwnerSplitStateCode nvarchar(255);

UPDATE  [house details data]
SET OwnerSplitStateCode = PARSENAME(replace(OwnerAddress,',','.'),1)


--DONE
--FOR CONFIRMATION
SELECT * 
FROM [House Details]..[house details data]



--CHANGING SOLD AS VACANT FROM 0 TO NO AND 1 TO YES
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 0 THEN 'No'
	ELSE 'Yes' END 
FROM [House Details]..[house details data]


--UPDATING THE TABLE
ALTER TABLE [house details data]
ADD NewSoldAsVacant nvarchar(10)

UPDATE  [house details data]
SET NewSoldAsVacant =CASE WHEN SoldAsVacant = 0 THEN 'No'
	ELSE 'Yes' END 

--DONE
-- FOR CONFIRMATION
SELECT *
FROM [House Details]..[house details data]





/*REMOVING THE DUPLICATE
DUPLICATE WILL BE THOSE THAT ARE THE SAME IN SOME UNIGUE COLUMN LIKE UNIQUEID, SALEDATE,LEGALREFERENCE*/
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
FROM [House Details]..[house details data]


--USING CTE TO ACCESS IT
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
FROM [House Details]..[house details data]
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
--THERE ARE 1594 ROWS WHICH ARE DUPLICATE OF ANOTHER 
--IT WILL BE DELETED

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
FROM [House Details]..[house details data]
)
DELETE
FROM RowNumCTE
WHERE row_num >1



--DUPLICATE DATA ARE GONE
SELECT *
FROM [House Details]..[house details data]


--REMOVING THE UNUSE COLUMN
/* Removing the Columns that have been splited to multiple columns
NOTE: I intend to do this because I am just Cleaning the data suppose I want to do the analysis of this
	  I won't drop the column until I'm done with analysis and the client is satisfy with it*/

ALTER TABLE [house details data]
DROP COLUMN PropertyAddress, OwnerAddress, SoldAsVacant

ALTER TABLE [house details data]
DROP COLUMN SoldAsVacant
SELECT *
FROM [House Details]..[house details data]




--CREATING VIEW
/* Creating View for Property Whose Owner's Name is Known*/
CREATE VIEW [PropertyWithOwnerName] AS
SELECT *
FROM [House Details]..[house details data]
WHERE OwnerName is not null


/* MANY MORE CAN STILL BE DONE DEPENDING ON WHAT THE DATA IS NEEDED FOR */


