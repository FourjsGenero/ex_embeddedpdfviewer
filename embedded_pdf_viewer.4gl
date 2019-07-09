IMPORT os
DEFINE current_page, page_count INTEGER

&define GENERO_REPORT_WRITER XML HANDLER grw
MAIN
DEFINE filename STRING
DEFINE save_page INTEGER

    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP
    DEFER INTERRUPT
    DEFER QUIT

    CLOSE WINDOW SCREEN
    OPEN WINDOW w WITH FORM "embedded_pdf_viewer"

    LET page_count = 0


    #comment out test cases
    LET filename = "http://4js.com/mirror/documentation.php?s=genero&f=fjs-genero-3.20.XX-PlatformsDb.pdf"

    INPUT BY NAME filename, current_page ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE, CANCEL=FALSE, ACCEPT=FALSE)
        BEFORE INPUT
            CALL state(DIALOG)

        ON ACTION view
            LET page_count = generate_svg_from_pdf(filename)
            IF page_count > 0 THEN
                LET current_page = 1
            END IF
            CALL display_page()
            CALL state(DIALOG)
            TRY
                CALL ui.Window.getCurrent().getForm().findNode("FormField","formonly.current_page").getFirstChild().setAttribute("valueMax",page_count)
            CATCH
                # ignore error
            END TRY

        ON ACTION first
            LET current_page = 1
             CALL display_page()
            CALL state(DIALOG)
            
        ON ACTION previous
            LET current_page = current_page - 1
            IF current_page < 1 THEN
                LET current_page = 1
            END IF
            CALL display_page()
            CALL state(DIALOG)

        ON ACTION go
            LET save_page = current_page
            PROMPT "Enter page number?" FOR current_page
            IF int_flag THEN
                LET current_page = save_page
                LET int_flag = 0
            ELSE
                IF current_page < 1 OR current_page > page_count THEN
                    ERROR "Page number not in range"
                    LET current_page = save_page
                END IF
            END IF
            CALL display_page()
            CALL state(DIALOG)
            

        ON ACTION next
            LET current_page = current_page + 1
            IF current_page > page_count THEN
                LET current_page = page_count
            END IF
            CALL display_page()
            CALL state(DIALOG)
            
        ON ACTION last
            LET current_page = page_count
            CALL display_page()
            CALL state(DIALOG)

        -- navigates via slider
        ON CHANGE current_page
            CALL display_page()
            CALL state(DIALOG)

        ON ACTION choose 
            -- To save typing, allow user to select from samples
            MENU "Choose" ATTRIBUTES(STYLE="dialog", COMMENT="Select PDF")
                ON ACTION c1 ATTRIBUTES(TEXT="HelloWorldSample")
                    LET filename = "HelloWorldSample.pdf"
                ON ACTION c2 ATTRIBUTES(TEXT="OrderReport")
                    LET filename = "OrderReport.pdf"
                ON ACTION c3 ATTRIBUTES(TEXT="Supported Systems Document")
                    LET filename = "http://4js.com/mirror/documentation.php?s=genero&f=fjs-genero-3.20.XX-PlatformsDb.pdf"
                ON ACTION c4 ATTRIBUTES(TEXT="Sales Brochure")
                    LET filename = "http://4js.com/files/documents/products/genero/genero_brochure.pdf"

                ON ACTION c5 ATTRIBUTES(TEXT="Genero PDF")
                    LET filename = "Genero.PDF"
                ON ACTION close
                    EXIT MENU
            END MENU

        ON ACTION close
            EXIT INPUT
            
    END INPUT
END MAIN

FUNCTION display_page()
    IF os.Path.exists(SFMT("pdf2svg%1.png", current_page USING "&&&&")) THEN
        DISPLAY (SFMT("pdf2svg%1.png", current_page USING "&&&&")) TO pdf
    ELSE
        CLEAR pdf
    END IF
END FUNCTION



FUNCTION state(d)
DEFINE d ui.Dialog

    CALL d.setActionActive("first", page_count > 0 AND current_page > 1)
    CALL d.setActionActive("previous", page_count > 0 AND current_page > 1)
    CALL d.setActionActive("go", page_count > 1)
    CALL d.setActionActive("next", page_count > 0 AND current_page < page_count)
    CALL d.setActionActive("last", page_count > 0 AND current_page < page_count)

    CALL d.setFieldActive("current_page", page_count > 1)
    DISPLAY (SFMT("Page %1 of %2", current_page, page_count)) TO xofy
END FUNCTION



FUNCTION generate_svg_from_pdf(filename)
DEFINE filename STRING
DEFINE grw om.SaxDocumentHandler
DEFINE i INTEGER
DEFINE l_img_filename STRING
DEFINE result STRING

    --delete existing files
    LET i = 0
    WHILE TRUE
        LET i = i + 1
        LET l_img_filename = SFMT("pdf2svg%1.png", i USING "&&&&")
        IF os.Path.exists(l_img_filename) THEN
            LET result = os.Path.delete(l_img_filename)
            -- TODO - should we exit if fails?
        ELSE
            EXIT WHILE
        END IF
        IF i >= 9999 THEN
            EXIT WHILE
        END IF
    END WHILE
        
       

    IF NOT fgl_report_loadCurrentSettings("embedded_pdf_viewer.4rp") THEN
        RETURN FALSE
    END IF
    CALL fgl_report_selectPreview(FALSE)
    CALL fgl_report_selectDevice("Image")
    CALL fgl_report_configureImageDevice(NULL,NULL,NULL,NULL,NULL, "png",NULL,"pdf2svg",NULL)

    LET grw = fgl_report_commitCurrentSettings()
    
    START REPORT pdf2svg TO GENERO_REPORT_WRITER
    OUTPUT TO REPORT pdf2svg(filename)
    FINISH REPORT pdf2svg

    -- see how many pages produced
    LET i = 0
    WHILE TRUE
        LET i = i + 1
        LET l_img_filename = SFMT("pdf2svg%1.png", i USING "&&&&")
        IF os.Path.exists(l_img_filename) THEN
            CONTINUE WHILE
        ELSE
            LET i = i - 1
            EXIT WHILE
        END IF
        IF i >= 9999 THEN
            EXIT WHILE
        END IF
    END WHILE    
    RETURN i
END FUNCTION



REPORT pdf2svg(filename)
DEFINE filename STRING

ORDER EXTERNAL BY filename

FORMAT

ON EVERY ROW
    PRINTX filename
END REPORT