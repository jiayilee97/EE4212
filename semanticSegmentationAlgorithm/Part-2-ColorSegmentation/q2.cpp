#include <cmath>
#include <iostream>
#include <opencv2/opencv.hpp>
#include "GCoptimization.h"

using namespace std;
using namespace cv;

int random_number(int n) 
{ 
	return rand() * 1.0 / RAND_MAX * n + 0.5; 
}


int main()
{
	typedef tuple<int, int, int> rgb;

	const double INF = 1e9;
	int K, H, W, *centroidR, *centroidG, *centroidB;
	Mat img;

	img = imread("img.png");
	H = img.rows; W = img.cols;
	cout << "Please specify the value of K: ";
	cin >> K;

	set<rgb> centroid;
	srand(time(NULL));
	while (centroid.size() < K) {
		int r = random_number(255), g = random_number(255), b = random_number(255);
		centroid.insert(make_tuple(r, g, b));
	}

	centroidR = new int[K], centroidG = new int[K], centroidB = new int[K];
	int m = 0;
	for (rgb e : centroid) {
		int r, g, b;
		tie(r, g, b) = e;
		centroidR[m] = r;
		centroidG[m] = g;
		centroidB[m] = b;
		++m;
	}
	int converge;
	do {
		converge = K;
		vector<rgb> *cluster = new vector<rgb>[K];
		// for every pixel, find the nearest centroid
		for (int i = 0; i < H; i++) {
			for (int j = 0; j < W; j++) {
				Vec3b p = img.at<Vec3b>(i, j);
				int b = p[0], g = p[1], r = p[2];
				int cluster_id = 0;
				double dist = INF;
				for (int k = 0; k < K; k++) {
					double cr, cg, cb;
					cr = centroidR[k], cg = centroidG[k], cb = centroidB[k];
					double tmpdist = sqrt(pow(cr - r, 2) + pow(cg - g, 2) + pow(cb - b, 2));
					if (tmpdist < dist) {
						dist = tmpdist;
						cluster_id = k;
					}
				}
				cluster[cluster_id].push_back(make_tuple(r, g, b));
			}
		}

		// calculate the new centroid to update every cluster
		for (int i = 0; i < K; i++) {
			int newcentroidR = 0, newcentroidG = 0, newcentroidB = 0;
			for (rgb e : cluster[i]) {
				int r, g, b;
				tie(r, g, b) = e;
				newcentroidR += r; newcentroidG += g; newcentroidB += b;
			}
			newcentroidR = newcentroidR * 1.0 / cluster[i].size() + 0.5;
			newcentroidG = newcentroidG * 1.0 / cluster[i].size() + 0.5;
			newcentroidB = newcentroidB * 1.0 / cluster[i].size() + 0.5;
			if (newcentroidR != centroidR[i] || newcentroidG != centroidG[i] || newcentroidB != centroidB[i]) {
				centroidR[i] = newcentroidR;
				centroidG[i] = newcentroidG;
				centroidB[i] = newcentroidB;
				converge--;
			}
		}
	} while (!converge);
	GCoptimizationGridGraph G(W, H, K);
	cout << "K centroids initialized.\n";
	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++) {
			int u = i * W + j;
			Vec3b pix = img.at<Vec3b>(i, j);
			uchar b = pix[0], g = pix[1], red = pix[2];
			for (int l = 0; l < K; l++) {
				int cost = sqrt(pow(red - centroidR[l], 2) + pow(g - centroidG[l], 2) +
					pow(b - centroidB[l], 2)) + 0.5;
				G.setDataCost(u, l, cost);
			}
		}
	}
	for (int k1 = 0; k1 < K; k1++) {
		for (int k2 = 0; k2 < K; k2++) {
			G.setSmoothCost(k1, k2, k1 == k2 ? 0 : 1);
		}
	}
	G.expansion(10);

	Mat outImg(H, W, CV_8UC3);
	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++) {
			Vec3b &p = outImg.at<Vec3b>(i, j);
			uchar &b = p[0], &g = p[1], &r = p[2];
			int u = i * W + j, l = G.whatLabel(u);
			r = centroidR[l], g = centroidG[l], b = centroidB[l];
		}
	}
	imwrite("outimage_" + to_string(K) + ".jpg", outImg);
	return 0;
}