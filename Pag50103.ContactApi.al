page 50103 "Contact Api"
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

                part(companyContact; 50108)
                {
                    EntityName = 'companyContact';
                    EntitySetName = 'companyContacts';
                    SubPageLink = "No." = FIELD("No.");
                }

                part(relations; 50102)
                {
                    EntityName = 'contactRelation';
                    EntitySetName = 'contactRelations';
                    SubPageLink = "Contact No." = FIELD("No.");
                }
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
            }
        }
    }
}
