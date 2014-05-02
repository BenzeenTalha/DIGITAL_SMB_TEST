global class UnifyProductAttributeUpdater {
	
	private static Map<Id, Map<String, String>> mapAttributeValues = new Map<Id, Map<String, String>>();
	
	public static Map<String, String> getAttributesForProduct(Id productId){
		return mapAttributeValues.get(productId);
	}
	
	public static void setAttributeValue(Id productId, String attributeName, String attributeValue){
		Map<String, String> attributes = getAttributesForProduct(productId);
		
		if(attributes == null){
			attributes = new Map<String, String>();
		}
		
		attributes.put(attributeName, attributeValue);
		
		mapAttributeValues.put(productId, attributes);
	}
	
	public static void removeProductFromMap(Id productId){
		mapAttributeValues.remove(productId);
	}

}