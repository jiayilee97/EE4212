
#include <cmath>
#include <iostream>
#include <opencv2/opencv.hpp>
#include "graph.h"

using namespace std;
using namespace cv;

const double INF = 1e9, lambda = 300;

const uchar FG[3] = { 0, 0, 255 }, BG[3] = { 245, 210, 110 };

double dist(int isFG, uchar r, uchar g, uchar b) {
	if (isFG) {																					
		if (r == BG[0] && g == BG[1] && b == BG[2])
			return INF;									
		double rdist = (double)(r - FG[0]);
		double gdist = (double)(g - FG[1]);
		double bdist = (double)(b - FG[2]);
		return sqrt(rdist * rdist + gdist * gdist + bdist * bdist);												
	}

	else {																						
		if (r == FG[0] && g == FG[1] && b == FG[2]) 
			return INF;									
		double rdist = (double)(r - BG[0]);
		double gdist = (double)(g - BG[1]);
		double bdist = (double)(b - BG[2]);	
		return sqrt(rdist * rdist + gdist * gdist + bdist * bdist);												
	}
}

int main()
{
	// load image
	Mat img = imread("MRF.jpg");
	int H = img.rows, W = img.cols;

	// construct graph
	typedef Graph<double, double, double> graph;
	graph G(H * W, 4 * H * W);

	G.add_node(H * W);

	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++) {
			Vec3b intensity = img.at<Vec3b>(i, j);
			uchar b = intensity.val[0];
			uchar g = intensity.val[1];
			uchar r = intensity.val[2];
			int u = i * W + j;

			// add weights between data and source/sink
			G.add_tweights(u, dist(1, r, g, b), dist(0, r, g, b));
			if (j < W - 1)
				G.add_edge(u, u + 1, lambda, lambda);
			if (i < H - 1)
				G.add_edge(u, u + W, lambda, lambda);
		}
	}
	G.maxflow();

	// reconstruct cleaned image
	Mat res(H, W, CV_8UC3);
	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++) {
			int u = i * W + j;
			Vec3b& intensity = res.at<Vec3b>(i, j);
			uchar& b = intensity.val[0];
			uchar& g = intensity.val[1];
			uchar& r = intensity.val[2];
			if (G.what_segment(u) == graph::SINK) {
				r = FG[0]; g = FG[1]; b = FG[2];
			}
			else {
				r = BG[0]; g = BG[1]; b = BG[2];
			}
		}
	}

	imwrite("result.jpg", res);
	return 0;
}