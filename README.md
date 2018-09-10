# ex_embeddedpdfviewer

An example of how to view PDF files inside a Genero Window, by using Genero Report Writer to create individual images of each page of a PDF document

<p align="center">
<img alt="Embedded PDF Viewer Screenshot" src="https://user-images.githubusercontent.com/13615993/29343909-5077e66c-8288-11e7-9b40-26889480a6c6.png" width="400" />
</p>

Two comments I will mention here in the README.

1. As the PDF has been converted to an Image, you will not have the ability to select and copy text.  If this is important to you then I would suggest having a button that enabled you to view the PDF document inside Adobe or a Browser by using shellexec or launchUrl front-calls respectively.

2. For large documents, it may take some time to convert all the pages to images.  What I would suggest is modifying the code so that only the first page is converted and displayed so that the first page is rendered and displayed quicker.  Then whilst user is viewing that page, convert the other pages in the background, or convert as required when user selects a page to view.

If you believe that the GDC should be able to view PDF documents just like a Browser Window, get yourself added to the list of requestors for GDC-3088.  It is dependent on the Qt libraries that we use for the GDC having the functionality.

Also have a read of http://4js.com/fjs_forum/index.php?topic=902.0, http://4js.com/fjs_forum/index.php?topic=1004.0, http://4js.com/fjs_forum/index.php?topic=1139.0 for other discussion and using a 3rd party web component pdf.js
