module zoneCalc
    use polygons
    implicit none

    ! ----------------------------------------------------------- !
    type(polygon) :: z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11, z12
    type(polygon), dimension(12) :: zoneList
    ! ----------------------------------------------------------- !

    contains
    subroutine assignZones()
        type(point), dimension(:), allocatable :: points
        character(:), allocatable :: name

        name = "sand"
        allocate(points(3))
        points%x = (/0.0, 0.5, 1.5/)
        points%y = (/0.0, 1.0, 0.0/)
        z1 = create_polygon(name, points)

        deallocate(points)

        name = "loamy sand"
        allocate(points(4))
        points%x = (/1.5, 0.5, 0.75, 3.0/)
        points%y = (/0.0, 1.0, 1.5, 0.0/)
        z2 = create_polygon(name, points)

        deallocate(points)

        name = "sandy loam"
        allocate(points(7))
        points%x = (/3.0, 0.75, 1.0, 3.75, 4.375, 5.375, 5.0/)
        points%y = (/0.0, 1.5, 2.0, 2.0, 0.75, 0.75, 0.0/)
        z3 = create_polygon(name, points)

        deallocate(points)

        name = "loam"
        allocate(points(5))
        points%x = (/4.375, 3.75, 4.125, 6.5, 5.375/)
        points%y = (/0.75, 2.0, 2.75, 2.75, 0.75/)
        z4 = create_polygon(name, points)

        deallocate(points)

        name = "silt loam"
        allocate(points(7))
        points%x = (/5.0, 6.5, 6.75, 8.75, 9.375, 8.75, 8.0/)
        points%y = (/0.0, 2.75, 2.75, 2.75, 1.25, 1.25, 0.0/)
        z5 = create_polygon(name, points)

        deallocate(points)

        name = "silt"
        allocate(points(4))
        points%x = (/8.0, 8.75, 9.5, 10.0/)
        points%y = (/0.0, 1.25, 1.25, 0.0/)
        z6 = create_polygon(name, points)

        deallocate(points)

        name = "sandy clay loam"
        allocate(points(5))
        points%x = (/1.0, 1.75, 3.75, 4.125, 3.75/)
        points%y = (/2.0, 3.5, 3.5, 2.75, 2.0/)
        z7 = create_polygon(name, points)

        deallocate(points)

        name = "clay loam"
        allocate(points(4))
        points%x = (/4.125, 3.5, 6.0, 6.75/)
        points%y = (/2.75, 4.0, 4.0, 2.75/)
        z8 = create_polygon(name, points)

        deallocate(points)

        name = "silty clay loam"
        allocate(points(4))
        points%x = (/6.75, 6.0, 8.0, 8.75/)
        points%y = (/2.75, 4.0, 4.0, 2.75/)
        z9 = create_polygon(name, points)

        deallocate(points)

        name = "sandy clay"
        allocate(points(3))
        points%x = (/1.75, 2.75, 3.75/) 
        points%y = (/3.5, 5.5, 3.5/)
        z10 = create_polygon(name, points)

        deallocate(points)

        name = "silty clay"
        allocate(points(3))
        points%x = (/6.0, 7.0, 8.0/) 
        points%y = (/4.0, 6.0, 4.0/)
        z11 = create_polygon(name, points)

        deallocate(points)

        name = "clay"
        allocate(points(5))
        points%x = (/3.5, 2.75, 5.0, 7.0, 6.0/)
        points%y = (/4.0, 5.5, 10.0, 6.0, 4.0/)
        z12 = create_polygon(name, points)

        deallocate(points)

        zoneList = (/z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11, z12/)
    end subroutine

    type(point) function getIntercept(a1, b1, c1, a2, b2, c2)
        real, intent(in) :: a1, b1, c1, a2, b2, c2
        type(point) :: intercept

        intercept%x = ((b1 * c2) - (b2 * c1)) / ((a1 * b2) - (a2 * b1))
        intercept%y = ((a2 * c1) - (a1 * c2)) / ((a1 * b2) - (a2 * b1))

        getIntercept = intercept
    end function getIntercept

    subroutine getPotentialZones(interceptPoint, potentialZones)
        type(point), intent(in) :: interceptPoint
        integer, dimension(4), intent(inout) :: potentialZones
        integer :: i, j, jMax, zoneCount
        real :: x, y, xPrime, yPrime, dist, minDist, potX, potY
        minDist = 30.0

        xPrime = interceptPoint%x
        yPrime = interceptPoint%y

        do i = 1, size(zoneList)
            jMax = size(zoneList(i)%vertices)
            do j = 1, jMax
                x = zoneList(i)%vertices(j)%x
                y = zoneList(i)%vertices(j)%y

                dist = abs(sqrt((xPrime-x)**2 + (yPrime-y)**2))

                if (dist < minDist) then
                    minDist = dist
                    potX = x
                    potY = y
                    write(*,*) "Point: ", potX, potY
                end if
            end do
        end do

        zoneCount = 1
        do i = 1, size(zoneList)
            jMax = size(zoneList(i)%vertices)
            do j = 1, jMax
                if (zoneList(i)%vertices(j)%x == potX .and. zoneList(i)%vertices(j)%y == potY) then
                    potentialZones(zoneCount) = i
                    zoneCount = zoneCount+1
                    write(*,*) "Test: ", zoneList(i)%vertices(j)
                end if
            end do
        end do
    end subroutine

    integer function cast(interceptPoint)
        type(point), intent(inout) :: interceptPoint
        integer :: i, j, k, jMax, kMax, index, interceptCount
        real :: y, yPrime, yMax, yMin
        integer, dimension(4) :: potentialZones = 0
        type(point) :: zoneIntercept
        type(polygon) :: currZone

        ! Get nearest point(s) and each zone with said point(s)
        call getPotentialZones(interceptPoint, potentialZones)
        write(*,*) potentialZones
        
        ! If there is a line connection in which one x value is to the right of intercept-x
        ! then the horizontal line will cross over
        ! -> Just count how many x values are to the right and that'll be how many times the 
        ! horiz line crosses (half right)
        ! -> Check that both y-values for the connection are different to confirm lines aren't parallel

        ! Points now ordered clockwise
        ! Check conns by iterating once through point list
        ! Does not need to wrap as end->start is always parallel to ray

        do i=1, size(potentialZones)
            interceptCount = 0
            if (potentialZones(i) /= 0) then
                currZone = zoneList(potentialZones(i))
                jMax = size(currZone%vertices)
                do j=1, jMax
                    if (currZone%vertices(j)%x >= interceptPoint%x) then
                        kMax = size(currZone%vertices)
                        do k=1, kMax
                            if (currZone%vertices(j)%x == currZone%vertices(k)%x .and. &
                                currZone%vertices(j)%y == currZone%vertices(k)%y) then
                                index = k
                            end if
                        end do
                        if (index == kMax) exit
                        y = currZone%vertices(index)%y
                        yPrime = currZone%vertices(index+1)%y
                        if (y > yPrime) then
                            yMax = y
                            yMin = yPrime
                        else
                            yMax = yPrime
                            yMin = y
                        end if

                        if (y /= yPrime) then
                            if (interceptPoint%y <= yMax .and. interceptPoint%y >= yMin) interceptCount = interceptCount+1
                        end if
                    end if
                end do
            end if
            write(*,*) currZone%name
            if (mod(interceptCount, 2) /= 0) exit
        end do

        write(*,*) "should be right name-> ", currZone%name

        cast = 0
    end function cast

    subroutine cleanZones()
        deallocate(z1%vertices)
        deallocate(z2%vertices)
        deallocate(z3%vertices)
        deallocate(z4%vertices)
        deallocate(z5%vertices)
        deallocate(z6%vertices)
        deallocate(z7%vertices)
        deallocate(z8%vertices)
        deallocate(z9%vertices)
        deallocate(z10%vertices)
        deallocate(z11%vertices)
        deallocate(z12%vertices)
    end subroutine

end module