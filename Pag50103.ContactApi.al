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
                field(companyNo; "Company No.") { }
                part(relations; 50102)
                {
                    EntityName = 'contactRelation';
                    EntitySetName = 'contactRelations';
                }
            }
        }
    }

}
