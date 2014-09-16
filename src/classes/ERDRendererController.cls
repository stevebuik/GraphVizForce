public class ERDRendererController {

	public String getGraph() {
		
		// Create Standard Group Map
		Map<String,List<String>> standardMap = new Map<String,List<String>>{
			'Sales' => new List<String>{
				'Account',
                'AccountContactRole',
                'Contact',
                'Contract',
                'ContractContactRole',
                'Opportunity',
                'OpportunityCompetitor',
                'OpportunityContactRole',
                'Order',
                'Partner',
                'PartnerRole'},
			'Marketing' => new List<String>{
                'Campaign',
                'CampaignMember',
                'Lead',
                'LeadStatus'},
			'Support' => new List<String>{
                'Asset',
                'Case',
                'CaseStatus',
                'Solution'},
			'Security' => new List<String>{
				'FieldPermissions',
                'ObjectPermissions',
                'PermissionSet',
                'PermissionSetAssignment',
                'Profile',
                'SetupEntityAccess',
                'User',
                'UserLicense'}
		};

		// Create Custom Group Map
		Map<String,List<String>> customMap = new Map<String,List<String>>{};
		
		// Generate ERD Graphviz content
		ERDGenerator generator = new ERDGenerator();
		return generator.generateERD(standardMap,customMap);
	
	}

}