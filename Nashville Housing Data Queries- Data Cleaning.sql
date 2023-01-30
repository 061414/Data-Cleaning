Select *From NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(Date,SaleDate) From NashvilleHousing 

Update NashvilleHousing
set SaleDate= Convert(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted= Convert(Date,SaleDate)

Select SaleDateConverted, Convert(Date,SaleDate) From NashvilleHousing 

----Populate Property Address data


Select *from NashvilleHousing order by ParcelID


Select Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress
from NashvilleHousing Nash1
Join NashvilleHousing Nash2
on Nash1.ParcelID=Nash2.ParcelID
and Nash1.[UniqueID ]<>Nash2.[UniqueID ]
where Nash1.PropertyAddress is null

Update Nash1
Set PropertyAddress=ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
from NashvilleHousing Nash1
Join NashvilleHousing Nash2
on Nash1.ParcelID=Nash2.ParcelID
and Nash1.[UniqueID ]<>Nash2.[UniqueID ]
where Nash1.PropertyAddress is null


---Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress From NashvilleHousing
--where Nash1.PropertyAddress is null

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address
From NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) 


--Let's separate Owner Address into Address, City, State

Select OwnerAddress From NashvilleHousing

Select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


Update NashvilleHousing
set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity= PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


---Change Y and N to Yes and No in "Sold As Vacant" Field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing

update NashvilleHousing
set SoldAsVacant= CASE when SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End


--Remove Duplicates

With RowNumCTE As(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by
			UniqueID
			) row_num

From NashvilleHousing
--order by ParcelID
)

Select * From RowNumCTE
where row_num>1
---order by PropertyAddress

To delete duplicates

With RowNumCTE As(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by
			UniqueID
			) row_num

From NashvilleHousing
--order by ParcelID
)

Delete From RowNumCTE
where row_num>1
---order by PropertyAddress


---Delete Unused Columns

Select *From NashvilleHousing


Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table NashvilleHousing
Drop Column SaleDate



