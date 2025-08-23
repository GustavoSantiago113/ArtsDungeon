# Art's Dungeon

![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=%23F7DF1E)![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?style=for-the-badge&logo=css3&logoColor=white)![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)

**[Link to the website](https://gustavosantiago.shinyapps.io/ArtsDungeon)** 

## Summary

1. [Purposes](#purposes)
2. [Frameworks used](#frameworks-used)
3. [Workflow](#workflow)

## Purposes

The main purpose of this app is to showcase the miniatures I paint. After painting them, I take the pictures using my cellphone, a lamp and a black background. Then, I use [MiniAid](https://github.com/GustavoSantiago113/MiniAid) to segment the main image and 3D reconstruct the miniature. Secondary purposes are:

* Connecting with other miniature painters;
* Improving my Shiny R skills;
* Improving my 3D reconstruction skills;
* Improving how I take marketing pictures. 

## Frameworks used

I used Shiny R to build the whole website. To display the 3D reconstruction, I used vtk.js. The image carousel is a simply CSS trick. For the email sending process, it was used the emayili package. To route pages, I used shiny.router.

## Workflow

1. Images and .ply files are locally stored.
2. When the website starts, it dynamically retrieves the segmented images and display them in the cards, according to the minis database in the csv file.

![Land page](readme_images/Screenshot%202025-06-18%20201117.png)

3. The user clicks in the mini text and the website is routed to the specific mini id.

![Specific Page](readme_images/Screenshot%202025-06-18%20201157.png)

4. The website retrieves images of the specific mini and displays them in the carousel.
5. When clicked in 3D, vtk.js retrieves the reconstructions and displays them in the screen.

![3D Page](readme_images/Screenshot%202025-06-18%20201217.png)

6. The contact is done by emailing myself with the content inserted using the emayili package.

![Email modal](readme_images/Screenshot%202025-06-18%20201230.png)