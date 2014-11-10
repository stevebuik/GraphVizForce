/*
Name: ERDListUtils
Purpose: 
This class is to provide utility functionalities for List Collection primitive
*/
public with sharing class ERDListUtils
{
    public static List<SObject> subList(Integer startIndex, Integer numOfItems, List<SObject> items)
    {
        if(items == null)
        {
            return null;
        }
        
        List<SObject> returnList = new List<SObject>();
        
        if(startIndex >= items.size() - 1)
        {
            throw new ERDException('start index can not be greater than the List size');
        }
        
        if(startIndex + numOfItems >= items.size() - 1)
        {
            throw new ERDException('subList is out of range of the List size');
        }
        
        Integer itemCount = 0;
        Integer itemIndex = startIndex;
        while(itemCount < numOfItems)
        {
            returnList.add(items[itemIndex]);
            itemCount++;
            itemIndex++;
        }
        
        return returnList;
    }
    
    public static Integer getStringItemIndex(String item, List<String> items)
    {
        if(items != null)
        {
            for(Integer i=0;i<items.size();i++)
            {
                String str = items[i];
                if(str == item)
                {
                    return i;
                }
            }
        }
        
        return -1;
    }
}