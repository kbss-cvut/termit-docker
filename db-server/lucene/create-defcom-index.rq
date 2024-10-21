PREFIX :<http://www.ontotext.com/connectors/lucene#>
PREFIX inst:<http://www.ontotext.com/connectors/lucene/instance#>
INSERT DATA {
	inst:defcom_index :createConnector '''
{
  "fields": [
    {
      "fieldName": "definition",
      "propertyChain": [
        "http://www.w3.org/2004/02/skos/core#definition"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    },
    {
      "fieldName": "scopeNote",
      "propertyChain": [
        "http://www.w3.org/2004/02/skos/core#scopeNote"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    },
    {
      "fieldName": "description",
      "propertyChain": [
        "http://purl.org/dc/terms/description"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    }
  ],
  "languages": [
    "cs"
  ],
  "types": [
    "http://www.w3.org/2004/02/skos/core#Concept",
    "http://onto.fel.cvut.cz/ontologies/slovník/agendový/popis-dat/pojem/slovník"
  ],
  "readonly": false,
  "detectFields": false,
  "importGraph": false,
  "skipInitialIndexing": false,
  "boostProperties": [],
  "stripMarkup": false,
  "analyzer": "org.apache.lucene.analysis.cz.CzechAnalyzer"
}
''' .
}