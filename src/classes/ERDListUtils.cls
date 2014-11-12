/*
Name: ERDListUtils
Purpose: 
This class is to provide utility functionalities for List Collection primitive
*/
public with sharing class ERDListUtils
{
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