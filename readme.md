### Business Central:
# Navigation in OData Webservices and Custom API

This is a spike project and my notes about my exploration into both [OData Webservices](#odata-web-services) and [custom APIs](#custom-apis) of Business Central. 

My attention is on querying object hierarchies with a single request using OData navigation features and its query option `$expand`. 

## Setup
### A simple relation between contacts

For this purpose, there is a simple table called `Tab50100.ContactRelation`.

``` AL
table 50100 "Contact Relation"
{
    Caption = 'Contact Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Contact No."; Code[20])
        {
            TableRelation = Contact ."No.";
        }
        field(3; "Relation to Contact No."; Code[20])
        {
            TableRelation = Contact."No.";
        }
        field(4; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        /* ...and some flow fields for convienience ... */
    }
    keys { key(PK; "No."){}}
}
```
For each contact, a list of their relationships (e.g. "Child" or "Partner of") to other contacts can now be stored. Therefore the table contains the two fields `Contact No` and `Relation to Contact No.` which handle the table relations to the built-in table `Contact` (5050).

### A Page for Editing

For a basic editing UI, I created a page of type list `Page50101.ContactRelation`:

``` AL
page 50101 "Contact Relation"
{
    ApplicationArea = All;
    Caption = 'Contact Relations';
    PageType = List;
    SourceTable = "Contact Relation";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Description"; Description)
                {
                    ApplicationArea = All;
                }
                field("Relation to Contact No."; "Relation to Contact No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
```
This allows me to enter a few relations:   
![Image of a few contact relations](assets/ContactRelationList.jpg)


## OData Web Services
Business Central allows to [publish page and queries](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/publish-web-service) as OData Web Services. 
To publish the page above, I navigate to the page `Web Services`, add a new one, and select page 50101 ContactRelation. The name of the service is also set to ContactRelation. After enabling, the service is available directly and can be queried.   

A get request to`{{serviceurl}}/ODataV4/Company('{{company}}')/ContactRelation` retrieves all entered contact relations as JSON. [Query options](https://www.odata.org/getting-started/basic-tutorial/#queryData) like `$filter` and `$select` allows to optimize requests. 

Part of OData is also the ability to obtain the Entity Data Model. The metadata is available at the service root with the URI `{{serviceurl}}/ODataV4/$metadata`. That document is an XML-based file format.

It also contains now our definition of Contact Relations:

```xml
<EntityType Name="ContactRelation">
    <Key>
        <PropertyRef Name="No" />
    </Key>
    <Property Name="No" Type="Edm.String" Nullable="false" MaxLength="10">
        <Annotation Term="NAV.LabelId" String="No" />
        <Annotation Term="NAV.NavType">
            <EnumMember>NAV.NavType/String</EnumMember>
        </Annotation>
        <Annotation Term="NAV.AllowEditOnCreate" Bool="true" />
    </Property>
    <Property Name="Contact_No" Type="Edm.String" MaxLength="20">
        <Annotation Term="NAV.LabelId" String="Contact_No" />
        <Annotation Term="NAV.NavType">
            <EnumMember>NAV.NavType/String</EnumMember>
        </Annotation>
    </Property>
    <Property Name="Description" Type="Edm.String" MaxLength="50">
        <Annotation Term="NAV.LabelId" String="Description" />
        <Annotation Term="NAV.NavType">
            <EnumMember>NAV.NavType/String</EnumMember>
        </Annotation>
    </Property>
    <Property Name="Relation_to_Contact_No" Type="Edm.String" MaxLength="20">
        <Annotation Term="NAV.LabelId" String="Relation_to_Contact_No" />
        <Annotation Term="NAV.NavType">
            <EnumMember>NAV.NavType/String</EnumMember>
        </Annotation>
    </Property>
    <Annotation Term="NAV.LabelId" String="ContactRelation" />
</EntityType>
```

The name of the entity type is defined by the name of the service and not by the name of the page or table. Fields are renamed to its Pascal case representation.

The [documentation](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/use-containments-associations) about associations and containment was not quite clear for me as a beginner in AL.

That's why I'll try out the concept in the next sections.

### Associations

OData also allows to include related resources within one single request using the query option `$expand`. In case of contact relations, it would be nice to include the contacts for Contact_No and Relation_to_Contact_No.

> Associations: When a field on a page has a TableRelation property, the specified table has a LookupPageId property that points to a different page. When you publish a page containing such a field as a web service, you must also publish the page that is pointed to by LookupPageId property. You can then link from the first page to the second page in a single URI.

Both fields are defined as `Table Relation`s to the contact table. That contact table, which is part of Busines Central, has a property `LookupPageID` which is set to `Page5052.Contact List`.

This page needs to be published as web service with the service name `Contact`. Afterward, the metadata has changed. It doesn't not only contains the entity type Contact, but it also adds navigation properties to the entity type ContactRelation:

```xml
<EntityType Name="ContactRelation">
    ...
    <NavigationProperty Name="Contact_No_Link" Type="Collection(NAV.Contact)" ContainsTarget="true" />
    <NavigationProperty Name="Relation_to_Contact_No_Link" Type="Collection(NAV.Contact)" ContainsTarget="true" />
    ...
</EntityType>
```

These associations have the name of the field with the table relation followed by `_Link`. Please note the type of navigation property. While a table relation is a lookup, which points to a single entity, the type indicates a _collection_ of type Contact.

`...ContactRelation('R01')?$expand=Relation_to_Contact_No_Link, Contact_No_Link` will return for our example data: 

```js
{
    "@odata.context": "{{serviceurl}}/$metadata#Company('{{company}}')/ContactRelation/$entity",
    "@odata.etag": "W/\"JzQ0O29SbGVDYm93dW5lbDBVVjlFcUdDV0EyVHF2V2R3Z3RUWml2NHVSZTZYcUU9MTswMDsn\"",
    "No": "R01",
    "Contact_No": "KT200058",
    "Description": "reports to",
    "Relation_to_Contact_No": "KT200038",
    "Contact_No_Link": [
        {
            "@odata.etag": "W/\"JzQ0O1RkTWthTXZ6SzNBNGJrY3hmeDZKTzFMaXBGUVpSMVRTeWoreWtjZ056YlU9MTswMDsn\"",
            "No": "KT200058",
            "Name": "Jan Christiansen",
            //... more fields
        }
    ],
    "Relation_to_Contact_No_Link": [
        {
            "@odata.etag": "W/\"JzQ0O3gwV05ZaVMyVElhTFgzZjVwWVVUdXhNUm92TWt4QWZqR2twQURVYTBIOHc9MTswMDsn\"",
            "No": "KT200038",
            "Name": "Karen Berg",
            //... more fields
        }
    ]
}

```
### Containments
On the other hand, when I query a contact, I also want to include its ContactRelations.

>Containments: Some pages in Business Central contain subpages. When you publish such a page, the subpages are automatically available in the web service as containments.

A subpage is for example just a page of type ListPart. Besides that, the main difference to a page of type List is that it cannot be called separately. Therefore a setting `UsageCategory` makes no sense here. 

```AL
page 50104 "Contact Relation Listpart"
{

    Caption = 'Contact Relations';
    PageType = ListPart;
    SourceTable = "Contact Relation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Description"; Description)
                {
                    ApplicationArea = All;
                }
                field("Contact Name"; "Contact Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

```

This list part has now to be added to the `page5052.Contact`(List) via a page extension.

```AL
pageextension 50105 "ContactRelationExtension" extends "Contact List"
{
    layout
    {
        addafter(Control1)
        {
            group("ContactRelGroup")
            {
                part("Relations"; "Contact Relation Listpart")
                {
                    SubPageLink = "Contact No." = FIELD("No.");
                }
            }
        }
    }
}
```
The group `ContactRelGroup` prevents the ContactRelation to appear as a list within UI as part of the contact list.

This page is already published for the association, so this adds immediately the following navigaton property to the contact type:

```xml
 <NavigationProperty Name="ContactRelations" Type="Collection(NAV.ContactRelations)" ContainsTarget="true" />
```
The name of the property combines the name of the service and the name of the part. 

`...Contact('KT200038')?$expand=ContactRelations` returns

```js
{
    "@odata.context": "http://bc160:7048/BC/ODataV4/$metadata#Company('Cronus%20AG')/Contact/$entity",
    "@odata.etag": "W/\"JzQ0O3gwV05ZaVMyVElhTFgzZjVwWVVUdXhNUm92TWt4QWZqR2twQURVYTBIOHc9MTswMDsn\"",
    "No": "KT200038",
    "Name": "Karen Berg",
    "Company_Name": "DanMøbler",
    // ....
    "ContactRelations": [
        {
            "@odata.etag": "W/\"JzQ0O0YvQnArR0ppdlR2MU0vNzNJWk9HV3pqeEdxSndxMnpOc0ZBc2orS3BpNGc9MTswMDsn\"",
            "No": "R02",
            "Contact_No": "KT200038",
            "Contact_Name": "Karen Berg",
            "Description": "reports to",
            "Relation_to_Contact_No": "KT200022",
            "Relation_to_Contact_Name": "Lone Kuhlmann"
        },
        {
            "@odata.etag": "W/\"JzQ0OzJHc0poang3ZGpIMkRmZGxubzVMOFlQM2ZXa1hmNzhDRHRZMjF4ZDJST2c9MTswMDsn\"",
            "No": "R03",
            "Contact_No": "KT200038",
            "Contact_Name": "Karen Berg",
            "Description": "is partner of",
            "Relation_to_Contact_No": "KT200025",
            "Relation_to_Contact_Name": "Ole Gotfred"
        }
    ]
}
```


Can we go one step deeper into the rabbit hole? Yes, we can!

* `Contact` offers containment for `ContactRelation`
* `ContactRelation` has an association to `Contact` 


Lets give it a try and lets query `...Contact('KT200038')?$expand=ContactRelations($expand=Relation_to_Contact_No_Link($expand=ContactRelations))`:

```js
{
    "@odata.context": "http://bc160:7048/BC/ODataV4/$metadata#Company('Cronus%20AG')/Contact/$entity",
    "@odata.etag": "W/\"JzQ0O3gwV05ZaVMyVElhTFgzZjVwWVVUdXhNUm92TWt4QWZqR2twQURVYTBIOHc9MTswMDsn\"",
    "No": "KT200038",
    "Name": "Karen Berg",
    "Company_Name": "DanMøbler",
    //...
    "ContactRelations": [
        {
            "@odata.etag": "W/\"JzQ0O0YvQnArR0ppdlR2MU0vNzNJWk9HV3pqeEdxSndxMnpOc0ZBc2orS3BpNGc9MTswMDsn\"",
            "No": "R02",
            "Contact_No": "KT200038",
            "Description": "reports to",
            //..
            "Relation_to_Contact_No_Link": [
                {
                    "@odata.etag": "W/\"JzQ0O0c0VXhSbWNFTEhPU05WVWpNbVVEV0VITzFaaUxydXJMT3ZWdkJWWitYY1E9MTswMDsn\"",
                    "No": "KT200022",
                    "Name": "Lone Kuhlmann",
                   // ..
                    "ContactRelations": []
                }
            ]
        },
        {
            "@odata.etag": "W/\"JzQ0OzJHc0poang3ZGpIMkRmZGxubzVMOFlQM2ZXa1hmNzhDRHRZMjF4ZDJST2c9MTswMDsn\"",
            "No": "R03",
            "Contact_No": "KT200038",
            "Contact_Name": "Karen Berg",
            "Description": "is partner of",
            //..
            "Relation_to_Contact_No_Link": [
                {
                    "@odata.etag": "W/\"JzQ0O2F6eHFDSzhnRndrMVlMNHRUMy9mejYxZ0M5UElLQjM1REtHeHRETVVDakk9MTswMDsn\"",
                    "No": "KT200025",
                    "Name": "Ole Gotfred",
                    // ..
                    "ContactRelations": [
                        {
                            "@odata.etag": "W/\"JzQ0O2Q0RmZiNXp1M0dDaWdFQnhRUnA2NkFLQXJ0K1kwdjJZUTc0WUZXUzc5cFE9MTswMDsn\"",
                            "No": "R04",
                            "Description": "cheats with",
                            "Relation_to_Contact_No": "KT200022",
                            "Relation_to_Contact_Name": "Lone Kuhlmann"
                        }
                    ]
                }
            ]
        }
    ]
}
```

## Custom APIs

Business Central introduced a new default API and also the ability to create custom APIs. These APIs do not reuse pages that were originally designed and intended for the user interface for web services. Besides, these APIs support versioning. A new [service endpoint](https://docs.microsoft.com/de-de/dynamics-nav/api-reference/v1.0/endpoints-apis-for-dynamics) must also be used.

Big advantage: Each API is decoupled from others and can develop on its own.

For this purpose, there is a new page type: API.

Following our example from above, a page for ContactRelations now looks like this:

```AL
page 50102 "Contact Relation API"
{
    PageType = API;
    APIGroup = 'query';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    EntityName = 'contactRelation';
    EntitySetName = 'contactRelations';
    ODataKeyFields = "No.";
    SourceTable = "Contact Relation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(contactNo; "Contact No.") { }
                field(description; "Description") { }
                field(relationToContactNo; "Relation to Contact No.") { }
            }
        }
    }
}
```

May I be forgiven for not using GUIDs as Ids here. Right now I just want to read, not write.

As you notice, a few changes in the properties of the page. ApplicationArea and UsageCategory make no sense any more, instead `APIGroup`, `APIPublisher`, and `APIVersion` have to be defined.

Also we define `EntityName` and `EntitySetName` here.

I also did not set any `ApplicationArea` or `Caption` for fields. Any value of caption is ignored anyway.

The data itself is again OData V4.

Therfore we can query $metadata and check the entity type:

```xml
<EntityType Name="contactRelation">
    <Key>
        <PropertyRef Name="number" />
    </Key>
    <Property Name="number" Type="Edm.String" Nullable="false" MaxLength="10" />
    <Property Name="contactNo" Type="Edm.String" MaxLength="20" />
    <Property Name="description" Type="Edm.String" MaxLength="50" />
    <Property Name="relationToContactNo" Type="Edm.String" MaxLength="20" />
</EntityType>
```
### Association

No navigation properties yet. Well, as the custom API is independent of the OData web service, it is required to define also an API for Contact:

``` al
page 50103 "Contact API"
{
    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'contact';
    EntitySetName = 'contacts';
    PageType = API;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(firstName; "First Name") { }
                field(surname; Surname) { }
                field(name; Name) { }
                field(companyNo; "Company No.") { }
            }
        }
    }
}
```

Now both `contactRelation` and `contact` are listed as types in $metadata:

```xml
<EntityType Name="contactRelation">
    <Key>
        <PropertyRef Name="number" />
    </Key>
    <Property Name="number" Type="Edm.String" Nullable="false" MaxLength="10" />
    <Property Name="contactNo" Type="Edm.String" MaxLength="20" />
    <Property Name="description" Type="Edm.String" MaxLength="50" />
    <Property Name="relationToContactNo" Type="Edm.String" MaxLength="20" />
    <NavigationProperty Name="contact" Type="Microsoft.NAV.contact" ContainsTarget="true" />
</EntityType>
<EntityType Name="contact">
    <Key>
        <PropertyRef Name="number" />
    </Key>
    <Property Name="number" Type="Edm.String" Nullable="false" MaxLength="20" />
    <Property Name="firstName" Type="Edm.String" MaxLength="30" />
    <Property Name="surname" Type="Edm.String" MaxLength="30" />
    <Property Name="name" Type="Edm.String" MaxLength="100" />
    <Property Name="id" Type="Edm.Guid" />
    <Property Name="companyNo" Type="Edm.String" MaxLength="20" />
    <NavigationProperty Name="contact" Type="Microsoft.NAV.contact" ContainsTarget="true" />
</EntityType>
```

Also, both types have now a _single_ navigation property `contact`. This looks weird to me, as I expected at least two navigation properties for contactRelation.

When I query the API with $expand and examine the data, it turns out that `contact` in contactRelation holds the contact for **contactNo**. Similarly when investigating the contact type, there the contact of the **companyNo** is revealed.

It turns out that when I change the order of the fields for Contact Relation Api and move the position of field relationToContactNo above the field contactNo, `contact` will hold the contact for **relationToContactNo**.



### Containments

Maybe we get more insight into containments.

Therefore I add the following part to ContactRelationApi:
```al
    part(relations; 50102)
    {
        EntityName = 'contactRelation';
        EntitySetName = 'contactRelations';
        SubPageLink = "Contact No." = FIELD("No.");
    }
```

Now the navigation properties for contact look like this:
```xml
<NavigationProperty Name="contactRelations" Type="Collection(Microsoft.NAV.contactRelation)" ContainsTarget="true" />
<NavigationProperty Name="contact" Type="Microsoft.NAV.contact" ContainsTarget="true" />
```
The name of the part relations is ignored. Instead, we have to declare EntityName and EntitySchema **again**. And it has to be the very same values as defined before on page 50102.

So far I have not found a way to get and use multiple navigation properties of the same type in one entity. And I dislike the idea that EntityName is used as the name of the navigation. Naming is serious, and should not be overridden by simple conventions like a sequence of fields.

### Refactoring Containments for Meaning

Maybe I was doing it wrong?

I wanna do queries. And I want them being meaningful. And maybe it is just wrong to look for multiple navigation properties.

Let us look at the Contact Relations again: 

The fields `Contact No.` and `Relation to Contact No.` represents a relation _from_ a contact _to_ a different contact. 
On a query, I wanna either know all relations from a contact to all relations pointing to that contact.

I should add new API pages for them that express these relations:

```al
page 50106 "Contact Relation To"
{
    PageType = API;
    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    EntityName = 'contactRelationTo';
    EntitySetName = 'contactRelationsTo';
    ODataKeyFields = "No.";
    SourceTable = "Contact Relation";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(description; "Description") { }
                field(relationToContactNo; "Relation to Contact No.") { }
            }
        }
    }
}

page 50107 "Contact Relation From"
{
    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    EntityName = 'contactRelationFrom';
    EntitySetName = 'contactRelationsFrom';
    ODataKeyFields = "No.";
    PageType = API;
    SourceTable = "Contact Relation";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(description; "Description") { }
                field(contactNo; "Contact No.") { }
            }
        }
    }
}
```
And we use these within the Contact API:
```al
    part(relationsToOthers; 50106)
    {
        EntityName = 'contactRelationTo';
        EntitySetName = 'contactRelationsTo';
        SubPageLink = "Contact No." = FIELD("No.");
    }
    part(relationsFromOthers; 50107)
    {
        EntityName = 'contactRelationFrom';
        EntitySetName = 'contactRelationsFrom';
        SubPageLink = "Relation to Contact No." = FIELD("No.");
    }
```
This results in following $metadata for contacts:
```xml
    <EntityType Name="contact">
        <Key>
            <PropertyRef Name="number" />
        </Key>
        <Property Name="number" Type="Edm.String" Nullable="false" MaxLength="20" />
        <Property Name="firstName" Type="Edm.String" MaxLength="30" />
        <Property Name="surname" Type="Edm.String" MaxLength="30" />
        <Property Name="name" Type="Edm.String" MaxLength="100" />
        <Property Name="companyNo" Type="Edm.String" MaxLength="20" />
        <NavigationProperty Name="contactRelations" Type="Collection(Microsoft.NAV.contactRelation)" ContainsTarget="true" />
        <NavigationProperty Name="contactRelationsTo" Type="Collection(Microsoft.NAV.contactRelationTo)" ContainsTarget="true" />
        <NavigationProperty Name="contactRelationsFrom" Type="Collection(Microsoft.NAV.contactRelationFrom)" ContainsTarget="true" />
        <NavigationProperty Name="contact" Type="Microsoft.NAV.contact" ContainsTarget="true" />
    </EntityType>
```
Much better. I still wish I could provide a better name for the navigation over `Company No.` than _contact_. However, now the relations look much better and more meaningful.

Here an example for a query and its result:   
`...contacts('KT200038')?$expand=contactRelationsTo($expand=contact), contactRelationsFrom($expand=contact)`
```json
{
    "@odata.context": "http://bc160:7048/BC/api/publisher/queries/v1.0/$metadata#companies(6febec3e-388d-ea11-bb38-001dd8b76686)/contacts/$entity",
    "@odata.etag": "W/\"JzQ0O1l0U2hET1B6VGplQU9leGZMRExsTkVBaExqS3VZaVMyc0xkSVZsS0NXZU09MTswMDsn\"",
    "number": "KT200038",
    "firstName": "Karen",
    "surname": "Berg",
    "name": "Karen Berg",
    "companyNo": "KT100016",
    "contactRelationsTo": [
        {
            "@odata.etag": "W/\"JzQ0O0lDTXBBd2M5SDVYMmhsOHZ3SHUya3hsamwraWkxbDBtZXBCbzVETWxHV1k9MTswMDsn\"",
            "number": "R02",
            "description": "reports to",
            "relationToContactNo": "KT200022",
            "contact": {
                "@odata.etag": "W/\"JzQ0O0x1VDVMVVF6ZG9LOEdqc3JxY29RU0dVMlNGcGVGb0RhaldMcGFxR09qZm89MTswMDsn\"",
                "number": "KT200022",
                "firstName": "Lone",
                "surname": "Kuhlmann",
                "name": "Lone Kuhlmann",
                "companyNo": "KT100016"
            }
        },
        {
            "@odata.etag": "W/\"JzQ0OytKK0VOY3psZnF4V21nMlpXWEE2YWhkbzh4U0hWK0IrV0FCd0tpdnE1R2c9MTswMDsn\"",
            "number": "R03",
            "description": "is partner of",
            "relationToContactNo": "KT200025",
            "contact": {
                "@odata.etag": "W/\"JzQ0O3hxL3FLRU50KzV6Wm1sYSt1cGNLSTJSWGwzNE80SVFyajhGLzRMM285aE09MTswMDsn\"",
                "number": "KT200025",
                "firstName": "Ole",
                "surname": "Gotfred",
                "name": "Ole Gotfred",
                "companyNo": "KT100016"
            }
        }
    ],
    "contactRelationsFrom": [
        {
            "@odata.etag": "W/\"JzQ0O1dadFFBblBUUmZPZkhuRXZRVmtLUXMvc2lENk9sSU5La0pyQWpTQTlBZms9MTswMDsn\"",
            "number": "R01",
            "description": "reports to",
            "contactNo": "KT200058",
            "contact": {
                "@odata.etag": "W/\"JzQ0O3k1YW9QUmJXWnhBRHpsV0ROVGQ4dHluODkweHF6UGlYLy9KeDlubU0rUkk9MTswMDsn\"",
                "number": "KT200058",
                "firstName": "Jan",
                "surname": "Christiansen",
                "name": "Jan Christiansen",
                "companyNo": "KT100016"
            }
        }
    ]
}
```
### Refactoring Associations as Containments

Can I use the same trick for associations? Of course!

Therefore I create a new page API `Company Contact`.

```al
page 50108 "Company Contact"
{

    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'companyContact';
    EntitySetName = 'companyContacts';
    PageType = API;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(companyNo; "Company No.") { }
                field(companyName; "Company Name") { }
            }
        }
    }
}
```

And, inside `Page50103.ContactApi`, I replace 

```al
    field(companyNo; "Company No.") { }
```

with 

```al
    part(companyContact; 50108)
    {
        EntityName = 'companyContact';
        EntitySetName = 'companyContacts';
        SubPageLink = "No." = FIELD("No.");
    }
```

For convenience, I have not yet raised the API number, as would be appropriate for such a breaking change.

But the `$metadata` changed. The more or less meaningless navigation property `contact` has been changed into a navigationProperty `companyContacts`.

```xml
<EntityType Name="contact">
    <Key>
        <PropertyRef Name="number" />
    </Key>
    <Property Name="number" Type="Edm.String" Nullable="false" MaxLength="20" />
    <Property Name="firstName" Type="Edm.String" MaxLength="30" />
    <Property Name="surname" Type="Edm.String" MaxLength="30" />
    <Property Name="name" Type="Edm.String" MaxLength="100" />
    <NavigationProperty Name="companyContacts" Type="Collection(Microsoft.NAV.companyContact)" ContainsTarget="true" />
    <NavigationProperty Name="contactRelations" Type="Collection(Microsoft.NAV.contactRelation)" ContainsTarget="true" />
    <NavigationProperty Name="contactRelationsTo" Type="Collection(Microsoft.NAV.contactRelationTo)" ContainsTarget="true" />
    <NavigationProperty Name="contactRelationsFrom" Type="Collection(Microsoft.NAV.contactRelationFrom)" ContainsTarget="true" />
</EntityType>
```

The cardinality still does not fit, there can only be one company contact linked to a contact. 

But now I can query for `contacts('KT200038')?$expand=companyContacts($expand=contact)`:
```json
{
    "@odata.context": "http://bc160:7048/BC/api/publisher/queries/v1.0/$metadata#companies(6febec3e-388d-ea11-bb38-001dd8b76686)/contacts/$entity",
    "@odata.etag": "W/\"JzQ0O2tnbU5SSG5nV2g4WVJyRzlSRjR5dWF6YmxaTXdEWk5nWVlRRjJ0OFAyRjA9MTswMDsn\"",
    "number": "KT200038",
    "firstName": "Karen",
    "surname": "Berg",
    "name": "Karen Berg",
    "companyContacts": [
        {
            "@odata.etag": "W/\"JzQ0Oy82eGlMT3pPWFBwR2hTcGgrVVdNMWswNEdTWUwvNzBGVVVLR1lKQ2Zhd0U9MTswMDsn\"",
            "no": "KT200038",
            "companyNo": "KT100016",
            "companyName": "DanMøbler",
            "contact": {
                "@odata.etag": "W/\"JzQ0O0EvTlQxYThHMUpzUCtQUzBhWXcvMkczdWNsU2NqS0FiSFJUTHprNnZSY0U9MTswMDsn\"",
                "number": "KT100016",
                "firstName": "",
                "surname": "",
                "name": "DanMøbler"
            }
        }
    ]
}
```

### Conclusion for Custom API
The direction Microsoft and Business Central are taking with the Custom API is the right one.
I appreciate the clean separation of APIs from other APIs or even the UI. They can develop without dependencies. 

Also, a simple association no longer results in a collection.  I also like that both required AL code and resulting $metadata are now denser.

You have to think differently about your queries. It is best to design any relation explicitly as own page and refer it as part, at least from a perspective of querying data. 