// Dependencies: Opencv for C++ (any version)
// How to download (for linux): sudo apt install libopencv-dev  
// (https://linuxconfig.org/install-opencv-on-ubuntu-18-04-bionic-beaver-linux)

// How to compile
// g++ *.cpp -o segment `pkg-config --cflags --libs opencv`
// This command will create an output file name segment. To run the output file
// ,type the command './segment' into the terminal 

#include <iostream>
#include <iomanip>

using namespace std;

#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

using namespace cv;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include "GCoptimization.h"

int euclidean_dist(int loc_1[],int loc_2[]){

    int d = (abs(loc_1[0]-loc_2[0]) +  
          abs(loc_1[1]-loc_2[1]) +  
          abs(loc_1[2]-loc_2[2]))/3; 

    return d;
}

int main( int argc, char** argv ) {
  int random;
  int k_means_colour[3];
  int k_means_colour_2[3];
  int current_pixel_colour[3];
  int node;
  int distance;
  int cluster_idx;
  int clusterCount;
  char filename[200]; //Saved file name
  char c[4]; //Segementation value
  char input_img[300];

  //Input the segmented value
  printf("Please input the number of segmentation classes below (positive integers only)\n");
  cin >> clusterCount;

  printf("Indicate the image filename(Image must be in the same directory)\n");
  cin >> input_img;

  // Loading of Image
  Mat src = imread(input_img , CV_LOAD_IMAGE_COLOR);
  Mat samples(src.rows * src.cols, 3, CV_32F);
  for( int y = 0; y < src.rows; y++ )
    for( int x = 0; x < src.cols; x++ )
      for( int z = 0; z < 3; z++)
        samples.at<float>(y + x*src.rows, z) = src.at<Vec3b>(y,x)[z];

  // K-Means Clustering
  Mat labels;
  int attempts = 5;
  Mat centers;
  kmeans(samples, clusterCount, labels, TermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS, 10000, 0.0001), 
        attempts, KMEANS_PP_CENTERS, centers );
  // cout << "Centers = "<< endl << " "  << centers << endl << endl;

  printf("The center values are:\n");
  for (int l = 0; l < clusterCount; l++ ){
    // Obtain the K-centered colour
    k_means_colour[0] = centers.at<float>(l, 0);
    k_means_colour[1] = centers.at<float>(l, 1);
    k_means_colour[2] = centers.at<float>(l, 2);
    printf("%d %d %d\n",k_means_colour[0],k_means_colour[1],k_means_colour[2]);
  }

  // // Segmentation directly using K-Means result
  // Mat new_image( src.size(), src.type() );
  // for( int x = 0; x < src.rows; x++ )
  //   for( int y = 0; y < src.cols; y++ )
  //   { 
  //     cluster_idx = labels.at<int>(x + y*src.rows,0);
  //     new_image.at<Vec3b>(x,y)[0] = centers.at<float>(cluster_idx, 0);
  //     new_image.at<Vec3b>(x,y)[1] = centers.at<float>(cluster_idx, 1);
  //     new_image.at<Vec3b>(x,y)[2] = centers.at<float>(cluster_idx, 2);
  //   }

  //Segmentation using binary graph cuts
  int width = src.rows;
  int height = src.cols;
  int num_pixels = src.rows * src.cols;
  int num_labels = clusterCount;
  int *result = new int[num_pixels];   // stores result of optimization

  try{
    GCoptimizationGridGraph *gc = new GCoptimizationGridGraph(width,height,num_labels);

    // Setting up data cost individually
    for (int y = 0; y < height; y++){
      for (int x = 0; x < width; x++){
        node = y * width + x;
        for (int l = 0; l < num_labels; l++ ){
          // Obtain the K-centered colour
          k_means_colour[0] = centers.at<float>(l, 0);
          k_means_colour[1] = centers.at<float>(l, 1);
          k_means_colour[2] = centers.at<float>(l, 2);

          // Obtain the pixel colour
          current_pixel_colour[0] = src.at<Vec3b>(x,y)[0];
          current_pixel_colour[1] = src.at<Vec3b>(x,y)[1];
          current_pixel_colour[2] = src.at<Vec3b>(x,y)[2];

          // Calculate the distance K-centered colour to pixel colour
          distance = euclidean_dist(k_means_colour,current_pixel_colour);

          //Set the data cost
          gc->setDataCost(node,l,distance);
        }
      }
    }

    printf("Data Cost loaded successfully\n");


    // next set up smoothness costs individually
    for ( int l1 = 0; l1 < num_labels; l1++ ){
      for (int l2 = 0; l2 < num_labels; l2++ ){
        k_means_colour[0] = centers.at<int>(l1, 0);
        k_means_colour[1] = centers.at<int>(l1, 1);
        k_means_colour[2] = centers.at<int>(l1, 2);

        k_means_colour_2[0] = centers.at<int>(l2, 0);
        k_means_colour_2[1] = centers.at<int>(l2, 1);
        k_means_colour_2[2] = centers.at<int>(l2, 2);

        distance = euclidean_dist(k_means_colour,k_means_colour_2);

        if (distance==0){
          gc->setSmoothCost(l1,l2,0); 
        }
        else{
          gc->setSmoothCost(l1,l2,1); 
        }
      }
    }

    printf("smoothness Cost loaded successfully\n");

    printf("Before optimization energy is %d\n",gc->compute_energy());
    gc->swap(100);
    gc->expansion(5);// run expansion for 2 iterations. For swap use gc->swap(num_iterations);
    printf("After optimization energy is %d\n",gc->compute_energy());


    //Print out the new results
    // for (int y = 0; y < height; y++){
    //   for (int x = 0; x < width; x++){
    //     node = y * width + x;
    //     result[node] = gc->whatLabel(node);
    //     printf("%d ",result[node]);        
    //   }
    //   printf("\n");
    // }

    Mat MRF_image( src.size(), src.type() );
    for( int x = 0; x < src.rows; x++ ){
      for( int y = 0; y < src.cols; y++ ){ 
        node = y * width + x;
        cluster_idx = gc->whatLabel(node);
        MRF_image.at<Vec3b>(x,y)[0] = centers.at<float>(cluster_idx, 0);
        MRF_image.at<Vec3b>(x,y)[1] = centers.at<float>(cluster_idx, 1);
        MRF_image.at<Vec3b>(x,y)[2] = centers.at<float>(cluster_idx, 2);
      }
    }

    strcpy(filename, "Segment_Image_");
    sprintf(c, "%d", clusterCount);
    strcat(filename, c);
    strcat(filename, ".jpg");

    imwrite(filename, MRF_image);
    printf("Segmented Image has been saved: %s\n",filename);

    // imshow(filename, MRF_image );
    // waitKey( 0 );

    delete gc;
  }
  catch (GCException e){
    e.Report();
  }

  // delete [] result;
}
