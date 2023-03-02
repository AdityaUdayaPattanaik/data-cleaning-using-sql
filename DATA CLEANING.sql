select * from housing   --to visualise the whole data and to get knowledge where should we start cleaning

--cleaning the project database

--standardize date format 



update housing
set saledate = convert(date,saledate)

alter table housing
add sellingdate date; 

update housing
set sellingdate = convert(date,saledate)

select sellingdate, convert(date, saledate)
from housing

-------------------------------------------------------------------
--property address data cleaning


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull(a.propertyAddress,b.PropertyAddress)
from housing a
join housing b
    on a.parcelID = b.ParcelID                              --used the same table in join with different variable name so that we make changes without harming the actual data
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress,b.propertyaddress)
from housing a
join housing b                         --USING UPDATE FUNCTION WE WILL CHANGE THE DATA IN THE TABLE 
    on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull(a.propertyAddress,b.PropertyAddress)
from housing a
join housing b
    on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------
-- breaking out address into individual columns (address,city,state)


select 
substring(propertyAddress,1,charindex(',',propertyAddress)-1) as Address,
substring(propertyAddress,charindex(',',PropertyAddress)+1,len(propertyAddress)) as main_address
from housing

alter table housing
add actual_address nvarchar(255); 

update housing
set actual_address = substring(propertyAddress,1,charindex(',',propertyAddress)-1)

alter table housing
add Propertycity nvarchar(255); 

update housing
set propertycity = substring(propertyAddress,charindex(',',PropertyAddress)+1,len(propertyAddress))

select *
from housing

----------------------------------------------------------------------
--for owneraddress

select 
parsename(replace(ownerAddress,',','.'),3),
parsename(replace(ownerAddress,',','.'),2),
parsename(replace(ownerAddress,',','.'),1)
from housing

alter table housing drop column owneraddress;

select * from housing

----------------------------------------------------------------------------------------

--changing of y and n to yes and no in "solid as vacant" colmn

select distinct(soldasvacant), count (soldasvacant)
from housing
group by SoldAsVacant
order by 2




select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end
from housing

update housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end

--------------------------------------------------------------------------------------
---removing duplicates in columns using sql 


with rownumcte as(
select *,
ROW_NUMBER() over(
partition by parcelid,
             propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by 
			    uniqueid
				) row_num
from housing
--order by ParcelID
)

--delete from rownumcte  --- used for deleting the duplicate rows
--where row_num > 1
--order by propertyaddress

select* from rownumcte
where row_num > 1
order by propertyaddress


-------------------------------------------------------------------------
---removal of unwanted column 

alter table housing 
drop column ownername, acreage, taxdistrict, buildingvalue,yearbuilt,
bedrooms,fullbath,halfbath, propertyaddress,saledate, owner_address,ownercity,ownerstate

alter table housing 
drop column landvalue,totalvalue

select * from housing