This is a spike project to explore both the REST Webservices and the new custom API of Business Central. My interest here is especially in the O-Data navigation features. I would like to query whole entity trees with only  a single call using $expand. The [documentation](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/use-containments-associations) I have found so far on the subject is extremely scarce and also outdated.  

### A simple relation beween contacts

For this purpose there is a simple table called `Tab50100.ContactRelation`.

```
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
For each contact a list of their relationships (e.g. "Child" or "Partner of") to other contacts can now be stored. Therefore the table contains the two fields `Contact No` and `Relation to Contact No.` which handle the table relations to the built in table `Contact` (5050).

### A Page for Editing

For a basic editing UI, I created a page of type list `Page50101.ContactRelation`:

```
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


### 
