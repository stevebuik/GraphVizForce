public with sharing class ERDDisplayType {
	
	public static final String LABEL_ANYTYPE = 'anytype';
	public static final String LABEL_BASE64 = 'base64';
	public static final String LABEL_BOOLEAN = 'Boolean';
	public static final String LABEL_COMBOBOX = 'Combobox';
	public static final String LABEL_CURRENCY = 'Currency';
	public static final String LABEL_DATA_CATEGORY_GROUP_REFERENCE = 'DataCategoryGroupReference';
	public static final String LABEL_DATE = 'Date';
	public static final String LABEL_DATETIME = 'DateTime';
	public static final String LABEL_DOUBLE = 'Double';
	public static final String LABEL_EMAIL = 'Email';
	public static final String LABEL_ENCRYPTEDSTRING = 'EncryptedString';
	public static final String LABEL_ID = 'ID';
	public static final String LABEL_INTEGER = 'Integer';
	public static final String LABEL_MULTIPICKLIST = 'MultiPicklist';
	public static final String LABEL_PERCENT = 'Percent';
	public static final String LABEL_PHONE = 'Phone';
	public static final String LABEL_PICKLIST = 'Picklist';
	public static final String LABEL_REFERENCE = 'Reference';
	public static final String LABEL_STRING = 'String';
	public static final String LABEL_TEXTAREA = 'TextArea';
	public static final String LABEL_TIME = 'Time';
	public static final String LABEL_URL = 'URL';
											
	public static String getDisplayTypeLabel(Schema.DisplayType displayTypeEnum)
	{
		if(displayTypeEnum == Schema.DisplayType.anytype) {return LABEL_ANYTYPE;}
	    if(displayTypeEnum == Schema.DisplayType.base64) {return LABEL_BASE64;}
	    if(displayTypeEnum == Schema.DisplayType.Boolean) {return LABEL_BOOLEAN;}
	    if(displayTypeEnum == Schema.DisplayType.Combobox) {return LABEL_COMBOBOX;}
	    if(displayTypeEnum == Schema.DisplayType.Currency) {return LABEL_CURRENCY;}
	    if(displayTypeEnum == Schema.DisplayType.DataCategoryGroupReference) {return LABEL_DATA_CATEGORY_GROUP_REFERENCE;}
	    if(displayTypeEnum == Schema.DisplayType.Date) {return LABEL_DATE;}
	    if(displayTypeEnum == Schema.DisplayType.DateTime) {return LABEL_DATETIME;}
	    if(displayTypeEnum == Schema.DisplayType.Double) {return LABEL_DOUBLE;}
	    if(displayTypeEnum == Schema.DisplayType.Email) {return LABEL_EMAIL;}
	    if(displayTypeEnum == Schema.DisplayType.EncryptedString) {return LABEL_ENCRYPTEDSTRING;}
	    if(displayTypeEnum == Schema.DisplayType.ID) {return LABEL_ID;}
	    if(displayTypeEnum == Schema.DisplayType.Integer) {return LABEL_INTEGER;}
	    if(displayTypeEnum == Schema.DisplayType.Percent) {return LABEL_PERCENT;}
	    if(displayTypeEnum == Schema.DisplayType.Phone) {return LABEL_PHONE;}
	    if(displayTypeEnum == Schema.DisplayType.Picklist) {return LABEL_PICKLIST;}
	    if(displayTypeEnum == Schema.DisplayType.Reference) {return LABEL_REFERENCE;}
	    if(displayTypeEnum == Schema.DisplayType.String) {return LABEL_STRING;}
	    if(displayTypeEnum == Schema.DisplayType.TextArea) {return LABEL_TEXTAREA;}
	    if(displayTypeEnum == Schema.DisplayType.Time) {return LABEL_TIME;}
	    if(displayTypeEnum == Schema.DisplayType.URL) {return LABEL_URL;}
	    
	    return '';
	}
}