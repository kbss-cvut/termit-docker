PREFIX :<http://www.ontotext.com/connectors/lucene#>
PREFIX inst:<http://www.ontotext.com/connectors/lucene/instance#>
INSERT DATA {
	inst:label_index :createConnector '''
{
  "fields": [
    {
      "fieldName": "prefLabel",
      "propertyChain": [
        "http://www.w3.org/2004/02/skos/core#prefLabel"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    },
    {
      "fieldName": "altLabel",
      "propertyChain": [
        "http://www.w3.org/2004/02/skos/core#altLabel"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    },
    {
      "fieldName": "hiddenLabel",
      "propertyChain": [
        "http://www.w3.org/2004/02/skos/core#hiddenLabel"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    },
    {
      "fieldName": "title",
      "propertyChain": [
        "http://purl.org/dc/terms/title"
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