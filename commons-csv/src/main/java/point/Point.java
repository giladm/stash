package point;

public class Point {

    private double xcor;
    private double ycor;

    public Point(double xcor, double ycor) {
        this.xcor = xcor;
        this.ycor = ycor;
    }

    public double getXcor() {
        return xcor;
    }

    public void setXcor(double xcor) {
        this.xcor = xcor;
    }

    public double getYcor() {
        return ycor;
    }

    public void setYcor(double ycor) {
        this.ycor = ycor;
    }

    @Override
    public String toString() {
        return "Point{" + "xcor=" + xcor + ", ycor=" + ycor + '}';
    }

}