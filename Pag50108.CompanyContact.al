page 50108 "CompanyContact"
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
