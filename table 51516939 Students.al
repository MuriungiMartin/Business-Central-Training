table 50100 Students
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; code[25])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Name"; text[150])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Academic Year"; integer)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Student Status"; enum "Student Status Enum")
        {
            DataClassification = ToBeClassified;

        }
        field(5; Registered; Boolean)
        {

        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(key2; "Academic Year")
        {

        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}

enum 50100 "Student Status Enum"
{
    Extensible = true;

    value(0; Active)
    {
    }
    value(1; Completed)
    {
    }
    value(2; Discontinued)
    {
    }
    value(3; Suspended)
    {
    }
}

page 50100 "Students List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Students;
    SourceTableView = where(Registered = filter(false));
    Caption = 'Non Registerd Students';
    CardPageId = "Students Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field(Name; Rec.Name)
                {

                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}

page 50101 "Students Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Students;

    layout
    {
        area(Content)
        {
            group(pdatails)
            {
                Caption = 'Personal Details';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }
            }
            group("ACD Details")
            {
                Caption = 'Academic Details';
                field("Academic Year"; Rec."Academic Year")
                {
                    ApplicationArea = All;

                }
                field("Student Status"; Rec."Student Status")
                {
                    ApplicationArea = All;

                }
                field(Registered; Rec.Registered)
                {
                    Editable = false;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RegStudents)
            {
                ApplicationArea = All;
                Caption = 'Register Students';
                promoted = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                begin
                    if Confirm('Do you want to register this user?') then begin
                        Rec.Registered := true;
                        Rec."Student Status" := Rec."Student Status"::Active;
                        Rec.Modify();
                    end else
                        exit;
                end;
            }
            action(ModifyStatus)
            {
                ApplicationArea = All;
                Caption = 'Discontinue Student';
                promoted = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                begin
                    if Confirm('Do you want to discontinue this student?') then begin
                        Rec."Student Status" := StudentCodeUnit.fnChangeStudentsStatus(Rec."No.", Rec."Student Status"::Discontinued);
                        Message('The student''s status has been set to %1 ', rec."Student Status");
                    end else
                        exit;
                end;
            }
        }
    }

    var
        StudentCodeUnit: Codeunit "Students Handling";
}
page 50102 "Registered Students"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Students;
    SourceTableView = where(Registered = filter(true));
    Caption = 'Registerd Students';
    CardPageId = "Students Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field(Name; Rec.Name)
                {

                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }

}

codeunit 50100 "Students Handling"
{
    trigger OnRun()
    begin

    end;



    procedure fnChangeStudentsStatus(var StudentNo: Code[25]; Status: enum "Student Status Enum"): Enum "Student Status Enum"
    var
        ObjStudents: Record Students;
        NewStatus: enum "Student Status Enum";
    begin
        if ObjStudents.Get(StudentNo) then begin
            ObjStudents."Student Status" := Status;
            NewStatus := ObjStudents."Student Status";
            ObjStudents.Modify();
            OnAfterDiscontinueStudent(ObjStudents);
        end;
        exit(NewStatus);

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterDiscontinueStudent(var bjStudents: Record Students)
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Students Handling", 'OnAfterDiscontinueStudent', '', false, false)]
    procedure fnModifyStudentRegistration(var bjStudents: Record Students)
    begin
        if bjStudents."Student Status" = bjStudents."Student Status"::Discontinued then begin
            bjStudents.Registered := false;
            bjStudents.Modify();
        end;
    end;

}

