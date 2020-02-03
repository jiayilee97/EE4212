// Dependencies: Opencv for C++ (any version)
// How to download (for linux): sudo apt install libopencv-dev  
// (https://linuxconfig.org/install-opencv-on-ubuntu-18-04-bionic-beaver-linux)

// How to compile: g++ *.cpp -o filter `pkg-config --cflags --libs opencv`
// This command will create an output file name filter. To run the output file
// ,type the command './filter' into the terminal 

#include <iostream>
#include <iomanip>

using namespace std;

#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

using namespace cv;

#include <stdio.h>
#include <math.h>
#include <string.h> 
#include "graph.h"


int euclidean_dist(int loc_1[],int loc_2[]){

    int d = (abs(loc_1[0]-loc_2[0]) +  
    			abs(loc_1[1]-loc_2[1]) +  
    			abs(loc_1[2]-loc_2[2]))/3; 

    return d;
}

int main(int argc, char* argv[]) {
	int W,H,D;
	int x,y,z;
	int current_pixel_colour[3];
	// int foreground_color[3] = {0,0,255};
	// int background_color[3] = {245,210,110};
	int foreground_color[3] = {255,0,0};
	int background_color[3] = {110,210,245};
	int node,right_node,bottom_node;
	int dist_1,dist_2;
	int m_lambda;
	char filename[200];
	char c[50]; //size of the number
	int flow;
	int save_image;
	int segment;

  	// Loading of Image
  	Mat src = imread("Image.jpg" , CV_LOAD_IMAGE_COLOR);
  	printf("Image loaded\n");
  	W = src.rows;
  	// printf("%d\n", W);
  	H = src.cols;
  	// printf("%d\n", H);

  	//Create a new matrix to store the filtered image
  	Mat filtered_image( src.size(), src.type() );

	// Loop the whole program for differen values of m_lambda
	for (m_lambda = 1 ; m_lambda < 500 ; m_lambda = m_lambda + 1){
  		// m_lambda = 1;

		cout << "The m_lambda value is " << m_lambda << endl;
		// Define the graph
		// 1st paramter: Estimated # of nodes, include bottom and right padding
		// 2nd paramter: Estimated # of edges, general formula (W-1)*H+(H-1)*W
		cout << "Loading Graph" << endl;
		typedef Graph<int,int,int> GraphType;
		GraphType *g = new GraphType( (W+1)*(H+1) , 2*W*H ); 
		cout << "Completed Loading" << endl;
		
		// Create the nodes
		g -> add_node((W+1)*(H+1)); 

	    for (y = 0; y < H-1; y++){
			for (x = 0; x < W-1; x++){

				node = y * W + x;
				current_pixel_colour[0] = src.at<Vec3b>(x,y)[0];
          		current_pixel_colour[1] = src.at<Vec3b>(x,y)[1];
          		current_pixel_colour[2] = src.at<Vec3b>(x,y)[2];

				// Calculate the distance bt foreground colour and current pixe colour
				dist_1 = euclidean_dist(foreground_color,current_pixel_colour);
				dist_2 = euclidean_dist(background_color,current_pixel_colour); 

				// Data Term
				g->add_tweights(node, dist_1, dist_2);

				// Smoothness Term
				right_node = y*W + (x+1);
				g->add_edge(node, right_node, m_lambda, m_lambda);
				bottom_node = (y+1)*W + x;
				g->add_edge(node, bottom_node, m_lambda, m_lambda);
			}
		}
		

		flow = g -> maxflow();
		printf("Maxflow algorithm implemented\n");

		for (y = 0; y < H; y++){
			for (x = 0; x < W ; x++){
				node = y * W + x;
				segment = g -> what_segment(node);
				filtered_image.at<Vec3b>(x,y)[0] = (segment==0) ? background_color[0]:foreground_color[0];
        		filtered_image.at<Vec3b>(x,y)[1] = (segment==0) ? background_color[1]:foreground_color[1];
        		filtered_image.at<Vec3b>(x,y)[2] = (segment==0) ? background_color[2]:foreground_color[2];
			}
		}

		printf("Saving Image as JPG format \n");

		strcpy(filename, "Denoise_Image_");
		sprintf(c, "%d", m_lambda);
		strcat(filename, c);
		strcat(filename, ".jpg");

		imwrite(filename, filtered_image);
    	printf("Filtered Image has been saved: %s\n",filename);

		delete g;
	}

	return 0;

}
